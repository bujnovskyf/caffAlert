import 'dart:async';

import 'package:flutter/foundation.dart';
import 'app_logger.dart';
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
  })  : _repository = repository,
        _now = now ?? DateTime.now {
    _repository.subscribeToLogs(userId, _handleRemoteChange);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _safeNotify());
    unawaited(refresh());
  }

  final String userId;
  final CoffeeDataSource _repository;
  final DateTime Function() _now;

  List<CoffeeLog> _logs = const [];
  Profile? _profile;
  bool _isLoading = true;
  bool _isMutating = false;
  CoffeeStateError? _error;
  Timer? _ticker;
  bool _isDisposed = false;

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
      await _repository.addCoffee(userId, now.toUtc());
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
    unawaited(_repository.dispose());
    super.dispose();
  }
}
