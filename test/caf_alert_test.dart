import 'dart:async';
import 'dart:io';

import 'package:caff_alert/caf_alert_notifications.dart';
import 'package:caff_alert/coffee_metrics.dart';
import 'package:caff_alert/coffee_repository.dart';
import 'package:caff_alert/coffee_stats_provider.dart';
import 'package:caff_alert/models/coffee_log.dart';
import 'package:caff_alert/models/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

class _Source implements CoffeeDataSource {
  _Source([List<CoffeeLog>? logs]) : logs = logs ?? [];

  final List<CoffeeLog> logs;
  Future<void> Function()? onChange;
  bool failFetch = false;
  Completer<void>? fetchGate;

  @override
  Future<CoffeeLog> addCoffee(String userId, DateTime createdAt) async {
    final log = CoffeeLog(
      id: logs.length + 100,
      userId: userId,
      createdAt: createdAt,
    );
    logs.insert(0, log);
    return log;
  }

  @override
  Future<CoffeeLog> updateCoffeeTime(int coffeeId, DateTime createdAt) async {
    final index = logs.indexWhere((log) => log.id == coffeeId);
    final updated = CoffeeLog(
      id: coffeeId,
      userId: logs[index].userId,
      createdAt: createdAt,
    );
    logs[index] = updated;
    logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return updated;
  }

  @override
  Future<CoffeeLog?> deleteCoffee(int coffeeId) async {
    final index = logs.indexWhere((log) => log.id == coffeeId);
    return index == -1 ? null : logs.removeAt(index);
  }

  @override
  Future<CoffeeLog?> deleteLatestCoffee() async =>
      logs.isEmpty ? null : logs.removeAt(0);

  @override
  Future<void> dispose() async {}

  @override
  Future<List<CoffeeLog>> fetchLogs(String userId) async {
    await fetchGate?.future;
    if (failFetch) throw StateError('offline');
    return List.of(logs);
  }

  @override
  Future<Profile?> fetchProfile(String userId) async => null;

  @override
  Future<void> saveDisplayName(String userId, String? displayName) async {}

  @override
  void subscribeToLogs(String userId, Future<void> Function() onChange) {
    this.onChange = onChange;
  }
}

class _FakeCafAlert implements CafAlertNotifications {
  _FakeCafAlert({
    this.enabled = false,
    this.grant = true,
    this.throwOnSchedule = false,
  });

  bool enabled;
  bool grant;
  bool throwOnSchedule;
  final calls = <String>[];
  DateTime? scheduledAt;

  @override
  bool get isSupported => true;

  @override
  Future<bool> isEnabled(String userId) async => enabled;

  @override
  Future<CafAlertToggleResult> setEnabled(String userId, bool value) async {
    if (!value) {
      enabled = false;
      return CafAlertToggleResult.disabled;
    }
    if (!grant) return CafAlertToggleResult.permissionDenied;
    enabled = true;
    return CafAlertToggleResult.enabled;
  }

  @override
  Future<void> schedule(DateTime atUtc) async {
    if (throwOnSchedule) throw StateError('platform channel missing');
    calls.add('schedule');
    scheduledAt = atUtc;
  }

  @override
  Future<void> cancel() async {
    calls.add('cancel');
    scheduledAt = null;
  }

  @override
  Future<void> cancelPending() async {
    calls.add('cancelPending');
    scheduledAt = null;
  }

  @override
  Future<void> openSystemSettings() async {}
}

class _FakePlugin implements FlutterLocalNotificationsPlugin {
  bool failInitialize = false;
  int initializeCalls = 0;
  List<PendingNotificationRequest> pending = const [];
  final cancelled = <int>[];

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    initializeCalls++;
    if (failInitialize) throw StateError('plugin not ready');
    return true;
  }

  @override
  Future<List<PendingNotificationRequest>>
      pendingNotificationRequests() async => pending;

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelled.add(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  // The app logger touches platform channels when an error is logged.
  TestWidgetsFlutterBinding.ensureInitialized();
  final logDirectory = Directory.systemTemp.createTempSync('caf_alert_test');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => logDirectory.path,
  );

  final now = DateTime.utc(2026, 11, 14, 10);
  CoffeeLog log(int id, Duration ago) =>
      CoffeeLog(id: id, userId: 'user-1', createdAt: now.subtract(ago));

  test('schedules at latest coffee + CAF duration once enabled', () async {
    final alert = _FakeCafAlert();
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: _Source([log(1, const Duration(hours: 1))]),
      now: () => now,
      cafAlert: alert,
    );
    addTearDown(provider.dispose);
    await provider.refresh();
    expect(alert.scheduledAt, isNull);

    expect(
      await provider.setCafAlertEnabled(true),
      CafAlertToggleResult.enabled,
    );
    expect(provider.cafAlertEnabled, isTrue);
    expect(
      alert.scheduledAt,
      now.subtract(const Duration(hours: 1)).add(CoffeeMetrics.duration),
    );
  });

  test('re-schedules on add, undo and remote change; idle refresh is a no-op',
      () async {
    final alert = _FakeCafAlert(enabled: true);
    final source = _Source([log(1, const Duration(hours: 1))]);
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: source,
      now: () => now,
      cafAlert: alert,
    );
    addTearDown(provider.dispose);
    await provider.refresh();
    await _settle();
    final first = now.subtract(const Duration(hours: 1)).add(
          CoffeeMetrics.duration,
        );
    expect(alert.scheduledAt, first);

    alert.calls.clear();
    await provider.refresh();
    await _settle();
    expect(alert.calls, isEmpty, reason: 'same latest coffee, no new call');

    expect(await provider.addCoffee(), isTrue);
    await _settle();
    expect(alert.scheduledAt, now.add(CoffeeMetrics.duration));

    expect(await provider.undoLastAddedCoffee(), isTrue);
    await _settle();
    expect(alert.scheduledAt, first);

    // Another device logs a coffee: realtime triggers a refresh.
    source.logs.insert(
      0,
      CoffeeLog(id: 50, userId: 'user-1', createdAt: now),
    );
    await source.onChange!();
    await _settle();
    expect(alert.scheduledAt, now.add(CoffeeMetrics.duration));
  });

  test('cancels when the countdown is already over or the user opts out',
      () async {
    final alert = _FakeCafAlert(enabled: true);
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: _Source([log(1, const Duration(hours: 5))]),
      now: () => now,
      cafAlert: alert,
    );
    addTearDown(provider.dispose);
    await provider.refresh();
    await _settle();
    // Only a pending reminder goes; one already shown stays in the shade.
    expect(alert.calls, isNot(contains('cancel')));
    expect(alert.calls.last, 'cancelPending');

    expect(await provider.addCoffee(), isTrue);
    await _settle();
    expect(alert.scheduledAt, isNotNull);

    expect(
      await provider.setCafAlertEnabled(false),
      CafAlertToggleResult.disabled,
    );
    expect(alert.scheduledAt, isNull);
    expect(provider.cafAlertEnabled, isFalse);
  });

  test('denied permission keeps the switch off', () async {
    final alert = _FakeCafAlert(grant: false);
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: _Source([log(1, const Duration(minutes: 5))]),
      now: () => now,
      cafAlert: alert,
    );
    addTearDown(provider.dispose);
    await provider.refresh();

    expect(
      await provider.setCafAlertEnabled(true),
      CafAlertToggleResult.permissionDenied,
    );
    expect(provider.cafAlertEnabled, isFalse);
    expect(alert.calls, isNot(contains('schedule')));
  });

  test('a failing notification plugin never breaks logging coffee', () async {
    final alert = _FakeCafAlert(enabled: true, throwOnSchedule: true);
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: _Source(),
      now: () => now,
      cafAlert: alert,
    );
    addTearDown(provider.dispose);
    await provider.refresh();

    expect(await provider.addCoffee(), isTrue);
    await _settle();
    expect(provider.logs, hasLength(1));
    expect(provider.error, isNull);
  });

  test('sign-out (provider dispose) cancels the pending reminder', () async {
    final alert = _FakeCafAlert(enabled: true);
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: _Source([log(1, const Duration(minutes: 5))]),
      now: () => now,
      cafAlert: alert,
    );
    await provider.refresh();
    await _settle();
    expect(alert.scheduledAt, isNotNull);

    provider.dispose();
    await _settle();
    expect(alert.calls.last, 'cancel');
    expect(alert.scheduledAt, isNull);
  });

  test('nothing is synced or cancelled before the first successful load',
      () async {
    final alert = _FakeCafAlert(enabled: true);
    final source = _Source([log(1, const Duration(hours: 1))])
      ..fetchGate = Completer<void>();
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: source,
      now: () => now,
      cafAlert: alert,
    );
    addTearDown(provider.dispose);
    // The opt-in is read while the logs are still loading: no "empty" sync.
    await _settle();
    await _settle();
    expect(alert.calls, isEmpty);

    source.fetchGate!.complete();
    await _settle();
    await _settle();
    expect(alert.calls, ['schedule']);
    expect(
      alert.scheduledAt,
      now.subtract(const Duration(hours: 1)).add(CoffeeMetrics.duration),
    );
  });

  test('a failed load never cancels the reminder', () async {
    final alert = _FakeCafAlert(enabled: true);
    final source = _Source([log(1, const Duration(hours: 1))])
      ..failFetch = true;
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: source,
      now: () => now,
      cafAlert: alert,
    );
    addTearDown(provider.dispose);
    await provider.refresh();
    await _settle();
    expect(provider.error, CoffeeStateError.load);
    expect(alert.calls, isEmpty);

    // Coming back online schedules it; a later failure leaves it alone.
    source.failFetch = false;
    await provider.refresh();
    await _settle();
    expect(alert.calls, ['schedule']);
    source.failFetch = true;
    await provider.refresh();
    await _settle();
    expect(alert.calls, ['schedule']);
  });

  group('LocalCafAlertNotifications', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('a failed initialize is retried on the next call', () async {
      final plugin = _FakePlugin()..failInitialize = true;
      final notifications = LocalCafAlertNotifications(
        preferredLocale: () => null,
        plugin: plugin,
      );
      await expectLater(notifications.cancel(), throwsStateError);
      plugin.failInitialize = false;
      await notifications.cancel();
      expect(plugin.initializeCalls, 2);
      expect(plugin.cancelled, [LocalCafAlertNotifications.notificationId]);

      // Initialized once, it is not repeated.
      await notifications.cancel();
      expect(plugin.initializeCalls, 2);
    });

    test('cancelPending leaves a reminder that already fired alone', () async {
      final plugin = _FakePlugin();
      final notifications = LocalCafAlertNotifications(
        preferredLocale: () => null,
        plugin: plugin,
      );
      await notifications.cancelPending();
      expect(plugin.cancelled, isEmpty);

      plugin.pending = const [
        PendingNotificationRequest(
          LocalCafAlertNotifications.notificationId,
          'CAF',
          null,
          null,
        ),
      ];
      await notifications.cancelPending();
      expect(plugin.cancelled, [LocalCafAlertNotifications.notificationId]);
    });
  });

  test('unsupported platforms (web) never touch notifications', () async {
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: _Source(),
      now: () => now,
    );
    addTearDown(provider.dispose);
    expect(provider.cafAlertSupported, isFalse);
    expect(
      await provider.setCafAlertEnabled(true),
      CafAlertToggleResult.failed,
    );
  });
}
