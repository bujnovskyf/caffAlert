import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import 'app_theme.dart';
import 'l10n/app_localizations.dart';

/// Outcome of the opt-in switch in settings.
enum CafAlertToggleResult { enabled, disabled, permissionDenied, failed }

/// The single "CAF at zero" reminder.
///
/// Everything stays on the device: the reminder is a local, inexact
/// notification scheduled for the moment the fictional CAF countdown of the
/// latest coffee ends. Nothing is sent to a server.
abstract interface class CafAlertNotifications {
  /// Whether this platform can show the reminder at all (Android only).
  bool get isSupported;

  /// Whether [userId] opted in on this device.
  Future<bool> isEnabled(String userId);

  /// Stores the choice. Enabling asks for the Android 13+ permission first and
  /// returns [CafAlertToggleResult.permissionDenied] when it is not granted.
  Future<CafAlertToggleResult> setEnabled(String userId, bool enabled);

  /// Replaces any pending reminder with one at [atUtc].
  Future<void> schedule(DateTime atUtc);

  /// Removes the reminder, pending or already shown.
  Future<void> cancel();

  /// Removes only a reminder that has not fired yet. One that is already in
  /// the notification shade stays visible.
  Future<void> cancelPending();

  /// Opens the system notification settings for this app.
  Future<void> openSystemSettings();
}

/// Used on the web, in tests and wherever reminders are not available.
class DisabledCafAlertNotifications implements CafAlertNotifications {
  const DisabledCafAlertNotifications();

  @override
  bool get isSupported => false;

  @override
  Future<bool> isEnabled(String userId) async => false;

  @override
  Future<CafAlertToggleResult> setEnabled(String userId, bool enabled) async =>
      CafAlertToggleResult.failed;

  @override
  Future<void> schedule(DateTime atUtc) async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> cancelPending() async {}

  @override
  Future<void> openSystemSettings() async {}
}

/// Android implementation backed by `flutter_local_notifications`.
class LocalCafAlertNotifications implements CafAlertNotifications {
  LocalCafAlertNotifications({
    required Locale? Function() preferredLocale,
    FlutterLocalNotificationsPlugin? plugin,
  })  : _preferredLocale = preferredLocale,
        _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const notificationId = 4040;
  static const channelId = 'caf_alert_zero';
  static const iconName = 'ic_stat_caf_alert';
  static const _enabledKeyPrefix = 'caf_alert_enabled_';

  final Locale? Function() _preferredLocale;
  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialization;

  @override
  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> _ensureInitialized() {
    final existing = _initialization;
    if (existing != null) return existing;
    // Tapping the notification simply launches the app's main activity, so no
    // response callback is needed.
    final attempt = _plugin
        .initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings(iconName),
          ),
        )
        .then<void>((_) {});
    _initialization = attempt;
    // A failed attempt must not be cached: the next call tries again.
    unawaited(attempt.then<void>((_) {}, onError: (Object _) {
      if (identical(_initialization, attempt)) _initialization = null;
    }));
    return attempt;
  }

  AppLocalizations _localizations() {
    final locale = _preferredLocale() ?? PlatformDispatcher.instance.locale;
    final supported = AppLocalizations.supportedLocales
        .any((value) => value.languageCode == locale.languageCode);
    return lookupAppLocalizations(
      supported ? Locale(locale.languageCode) : const Locale('en'),
    );
  }

  @override
  Future<bool> isEnabled(String userId) async {
    if (!isSupported) return false;
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool('$_enabledKeyPrefix$userId') ?? false;
  }

  @override
  Future<CafAlertToggleResult> setEnabled(String userId, bool enabled) async {
    if (!isSupported) return CafAlertToggleResult.failed;
    final preferences = await SharedPreferences.getInstance();
    final key = '$_enabledKeyPrefix$userId';
    if (!enabled) {
      await preferences.setBool(key, false);
      await cancel();
      return CafAlertToggleResult.disabled;
    }

    await _ensureInitialized();
    final granted = await _android?.requestNotificationsPermission() ?? false;
    if (!granted) {
      await preferences.setBool(key, false);
      return CafAlertToggleResult.permissionDenied;
    }
    await preferences.setBool(key, true);
    return CafAlertToggleResult.enabled;
  }

  @override
  Future<void> schedule(DateTime atUtc) async {
    if (!isSupported) return;
    await _ensureInitialized();
    final localizations = _localizations();
    // The reminder is an absolute instant, so UTC avoids the need for a
    // timezone database on the device.
    final scheduledDate = tz.TZDateTime.from(atUtc.toUtc(), tz.UTC);
    await _plugin.cancel(id: notificationId);
    await _plugin.zonedSchedule(
      id: notificationId,
      title: localizations.cafAlertNotificationTitle,
      body: localizations.cafAlertNotificationBody,
      scheduledDate: scheduledDate,
      // Inexact on purpose: no SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          localizations.cafAlertChannelName,
          channelDescription: localizations.cafAlertChannelDescription,
          icon: iconName,
          color: AppColors.caramel,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
  }

  @override
  Future<void> cancel() async {
    if (!isSupported) return;
    await _ensureInitialized();
    await _plugin.cancel(id: notificationId);
  }

  @override
  Future<void> cancelPending() async {
    if (!isSupported) return;
    await _ensureInitialized();
    final pending = await _plugin.pendingNotificationRequests();
    if (pending.any((request) => request.id == notificationId)) {
      await _plugin.cancel(id: notificationId);
    }
  }

  @override
  Future<void> openSystemSettings() async {
    if (!isSupported) return;
    await _ensureInitialized();
    await _android?.openAppNotificationSettings();
  }
}
