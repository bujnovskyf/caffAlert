import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_logger.dart';
import 'caf_alert_notifications.dart';
import 'caff_alert_home_widget.dart';
import 'coffee_metrics.dart';
import 'coffee_repository.dart';
import 'models/coffee_log.dart';
import 'models/profile.dart';

enum CoffeeStateError { load, add, update, delete, profile }

class CoffeeStatsProvider extends ChangeNotifier {
  static const coffeeEditWindow = Duration(hours: 24);

  CoffeeStatsProvider({
    required this.userId,
    required CoffeeDataSource repository,
    DateTime Function()? now,
    CafAlertNotifications cafAlert = const DisabledCafAlertNotifications(),
  })  : _repository = repository,
        _now = now ?? DateTime.now,
        _cafAlert = cafAlert {
    _repository.subscribeToLogs(userId, _handleRemoteChange);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _safeNotify());
    unawaited(refresh());
    unawaited(_loadCafAlertPreference());
  }

  final String userId;
  final CoffeeDataSource _repository;
  final DateTime Function() _now;
  final CafAlertNotifications _cafAlert;

  List<CoffeeLog> _logs = const [];
  Profile? _profile;
  bool _isLoading = true;
  bool _isMutating = false;
  CoffeeStateError? _error;
  Timer? _ticker;
  bool _isDisposed = false;
  CoffeeLog? _lastAddedCoffee;
  bool _cafAlertEnabled = false;
  bool _isChangingCafAlert = false;
  // What the reminder is currently scheduled for; avoids re-scheduling the
  // same instant on every refresh. `_cafAlertSynced` is false until the first
  // sync, so the very first one always reaches the platform.
  bool _cafAlertSynced = false;
  DateTime? _cafAlertScheduledFor;
  // Reminder syncs wait for the first successful load of logs and of the
  // opt-in: before that "no coffee" or "off" would only be a placeholder, and
  // acting on it would cancel a perfectly valid reminder.
  bool _hasLoadedLogs = false;
  bool _hasLoadedCafAlertPreference = false;
  Future<void> _cafAlertQueue = Future.value();

  List<CoffeeLog> get logs => List.unmodifiable(_logs);
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  CoffeeStateError? get error => _error;
  DateTime get now => _now();
  Duration get remaining => CoffeeMetrics.remaining(_logs, now);
  bool get isReady => remaining == Duration.zero;
  double get timerProgress =>
      remaining.inMilliseconds / CoffeeMetrics.duration.inMilliseconds;
  int get caffLevelPercent => CoffeeMetrics.caffLevelPercent(_logs, now);
  Duration get caffLevelDuration => CoffeeMetrics.duration;
  CoffeeStatus get coffeeStatus =>
      CoffeeMetrics.statusForDailyCoffees(dailyCoffees);
  CoffeeLog? get latestCoffee => CoffeeMetrics.latest(_logs);

  /// Local time at which the CAF countdown of the latest coffee hits zero.
  DateTime? get caffZeroAt => CoffeeMetrics.zeroAt(_logs)?.toLocal();
  List<CoffeeLog> get coffeesToday => CoffeeMetrics.today(_logs, now).toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  bool get cafAlertSupported => _cafAlert.isSupported;
  bool get cafAlertEnabled => _cafAlertEnabled;
  bool get isChangingCafAlert => _isChangingCafAlert;
  List<CoffeeLog> get editableCoffees => _logs.where(canEditCoffee).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  bool canEditCoffee(CoffeeLog coffee) =>
      !coffee.createdAt.isBefore(now.toUtc().subtract(coffeeEditWindow));

  CoffeeLog? get firstCoffeeToday => CoffeeMetrics.firstToday(_logs, now);
  CoffeeLog? get lastCoffeeToday => CoffeeMetrics.lastToday(_logs, now);
  Duration? get averageIntervalToday =>
      CoffeeMetrics.averageIntervalToday(_logs, now);
  int get dailyCoffees => CoffeeMetrics.today(_logs, now).length;
  int get monthlyCoffees => CoffeeMetrics.monthlyCount(_logs, now);
  int get totalCoffees => _logs.length;

  Future<void> refresh({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _safeNotify();
    }
    try {
      final results = await Future.wait<dynamic>([
        _repository.fetchLogs(userId),
        _repository.fetchProfile(userId),
      ]);
      if (_isDisposed) return;
      _logs = results[0] as List<CoffeeLog>;
      _profile = results[1] as Profile?;
      _error = null;
      _hasLoadedLogs = true;
      unawaited(
        CaffAlertHomeWidget.sync(
          latestCoffee: latestCoffee,
          duration: caffLevelDuration,
        ),
      );
      unawaited(_syncCafAlert());
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        'Failed to load coffee data',
        error: error,
        stackTrace: stackTrace,
      );
      _error = CoffeeStateError.load;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> addCoffee() async {
    if (_isMutating) return false;
    _isMutating = true;
    _error = null;
    _safeNotify();
    try {
      _lastAddedCoffee = await _repository.addCoffee(userId, now.toUtc());
      await refresh(silent: true);
      return true;
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        'Failed to add coffee',
        error: error,
        stackTrace: stackTrace,
      );
      _error = CoffeeStateError.add;
      return false;
    } finally {
      _isMutating = false;
      _safeNotify();
    }
  }

  Future<bool> updateCoffeeTime(CoffeeLog coffee, DateTime createdAt) async {
    final nowUtc = now.toUtc();
    final earliestAllowed = nowUtc.subtract(coffeeEditWindow);
    final correctedTime = createdAt.toUtc();
    if (_isMutating ||
        !canEditCoffee(coffee) ||
        correctedTime.isBefore(earliestAllowed) ||
        correctedTime.isAfter(nowUtc)) {
      return false;
    }

    _isMutating = true;
    _error = null;
    _safeNotify();
    try {
      await _repository.updateCoffeeTime(coffee.id, correctedTime);
      await refresh(silent: true);
      return true;
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        'Failed to update coffee time',
        error: error,
        stackTrace: stackTrace,
      );
      _error = CoffeeStateError.update;
      return false;
    } finally {
      _isMutating = false;
      _safeNotify();
    }
  }

  Future<bool> removeLatestCoffee() async {
    if (_isMutating || _logs.isEmpty) return false;
    _isMutating = true;
    _error = null;
    _safeNotify();
    try {
      final deleted = await _repository.deleteLatestCoffee();
      await refresh(silent: true);
      return deleted != null;
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        'Failed to remove latest coffee',
        error: error,
        stackTrace: stackTrace,
      );
      _error = CoffeeStateError.delete;
      return false;
    } finally {
      _isMutating = false;
      _safeNotify();
    }
  }

  /// Undo for the snackbar right after logging: removes exactly the coffee
  /// that was just added, even if another device logged one in between.
  Future<bool> undoLastAddedCoffee() async {
    final coffee = _lastAddedCoffee;
    if (coffee == null) return false;
    final success = await removeCoffee(coffee);
    if (success) _lastAddedCoffee = null;
    return success;
  }

  Future<bool> removeCoffee(CoffeeLog coffee) async {
    if (_isMutating || !canEditCoffee(coffee)) return false;
    _isMutating = true;
    _error = null;
    _safeNotify();
    try {
      final deleted = await _repository.deleteCoffee(coffee.id);
      await refresh(silent: true);
      return deleted != null;
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        'Failed to remove coffee',
        error: error,
        stackTrace: stackTrace,
      );
      _error = CoffeeStateError.delete;
      return false;
    } finally {
      _isMutating = false;
      _safeNotify();
    }
  }

  Future<bool> saveDisplayName(String value) async {
    if (_isMutating) return false;
    final normalized = value.trim();
    _isMutating = true;
    _error = null;
    _safeNotify();
    try {
      await _repository.saveDisplayName(
        userId,
        normalized.isEmpty ? null : normalized,
      );
      await refresh(silent: true);
      return true;
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        'Failed to save profile',
        error: error,
        stackTrace: stackTrace,
      );
      _error = CoffeeStateError.profile;
      return false;
    } finally {
      _isMutating = false;
      _safeNotify();
    }
  }

  /// Turns the "CAF at zero" reminder on or off for this user on this device.
  Future<CafAlertToggleResult> setCafAlertEnabled(bool enabled) async {
    if (!_cafAlert.isSupported || _isChangingCafAlert) {
      return CafAlertToggleResult.failed;
    }
    _isChangingCafAlert = true;
    _safeNotify();
    try {
      final result = await _cafAlert.setEnabled(userId, enabled);
      _cafAlertEnabled = result == CafAlertToggleResult.enabled;
      _hasLoadedCafAlertPreference = true;
      _cafAlertSynced = false;
      await _syncCafAlert();
      return result;
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        'Failed to change CAF alert',
        error: error,
        stackTrace: stackTrace,
      );
      return CafAlertToggleResult.failed;
    } finally {
      _isChangingCafAlert = false;
      _safeNotify();
    }
  }

  Future<void> openCafAlertSystemSettings() async {
    try {
      await _cafAlert.openSystemSettings();
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        'Failed to open notification settings',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Re-schedules the reminder, e.g. after a language change (new texts).
  Future<void> resyncCafAlert() {
    _cafAlertSynced = false;
    return _syncCafAlert();
  }

  Future<void> _loadCafAlertPreference() async {
    if (!_cafAlert.isSupported) return;
    try {
      final enabled = await _cafAlert.isEnabled(userId);
      if (_isDisposed) return;
      _cafAlertEnabled = enabled;
      _hasLoadedCafAlertPreference = true;
      _cafAlertSynced = false;
      _safeNotify();
      await _syncCafAlert();
    } catch (error, stackTrace) {
      AppLogger.logger.e(
        'Failed to read CAF alert preference',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Keeps the single reminder in line with the latest coffee. Never throws:
  /// a notification problem must not break logging coffee.
  ///
  /// It only acts when the latest coffee or the opt-in changes, never just
  /// because time passed. Nothing happens before the first successful load,
  /// and a reminder that already fired stays visible: only a pending one is
  /// removed (switching the reminder off and signing out remove both).
  Future<void> _syncCafAlert() async {
    if (_isDisposed ||
        !_cafAlert.isSupported ||
        !_hasLoadedLogs ||
        !_hasLoadedCafAlertPreference) {
      return;
    }
    final zeroAt = _cafAlertEnabled ? CoffeeMetrics.zeroAt(_logs) : null;
    if (_cafAlertSynced && zeroAt == _cafAlertScheduledFor) return;
    _cafAlertSynced = true;
    _cafAlertScheduledFor = zeroAt;
    final shouldSchedule = zeroAt != null && zeroAt.isAfter(now.toUtc());
    try {
      await _enqueueCafAlert(
        () => shouldSchedule
            ? _cafAlert.schedule(zeroAt)
            : _cafAlert.cancelPending(),
      );
    } catch (error, stackTrace) {
      _cafAlertSynced = false;
      AppLogger.logger.e(
        'Failed to sync CAF alert',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Platform calls run one after another so a slow schedule can never land
  /// after a newer cancel.
  Future<void> _enqueueCafAlert(Future<void> Function() operation) {
    final next = _cafAlertQueue.then((_) => operation());
    _cafAlertQueue = next.catchError((Object _) {});
    return next;
  }

  void clearError() {
    _error = null;
    _safeNotify();
  }

  Future<void> _handleRemoteChange() => refresh(silent: true);

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _ticker?.cancel();
    unawaited(CaffAlertHomeWidget.clear());
    // Signing out or deleting the account disposes this provider: the reminder
    // must not fire for a user who is no longer here.
    if (_cafAlert.isSupported) {
      unawaited(
        _enqueueCafAlert(_cafAlert.cancel).catchError((Object error) {
          AppLogger.logger.e('Failed to cancel CAF alert', error: error);
        }),
      );
    }
    unawaited(_repository.dispose());
    super.dispose();
  }
}
