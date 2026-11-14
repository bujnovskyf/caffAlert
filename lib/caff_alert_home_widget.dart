import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import 'models/coffee_log.dart';

/// Keeps the native Android home-screen widget in sync with the latest log.
abstract final class CaffAlertHomeWidget {
  static const _providerName = 'CaffAlertWidgetProvider';
  static const _qualifiedProviderName =
      'com.frantisekbujnovsky.caffalert.CaffAlertWidgetProvider';
  static const _latestCoffeeKey = 'caff_alert_latest_coffee_millis';
  static const _durationKey = 'caff_alert_duration_seconds';

  static String? _lastLanguage;

  /// Launcher resources use the device language unless we pass the app locale.
  static Future<void> syncLanguage(String languageCode) async {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        _lastLanguage == languageCode) {
      return;
    }
    _lastLanguage = languageCode;
    try {
      await HomeWidget.saveWidgetData<String>(
        'caff_alert_language',
        languageCode,
      );
      await HomeWidget.updateWidget(
        name: _providerName,
        androidName: _providerName,
        qualifiedAndroidName: _qualifiedProviderName,
      );
    } catch (_) {
      if (_lastLanguage == languageCode) _lastLanguage = null;
    }
  }

  static Future<void> sync({
    required CoffeeLog? latestCoffee,
    required Duration duration,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>(
          _latestCoffeeKey,
          latestCoffee?.createdAt.toUtc().millisecondsSinceEpoch.toString() ??
              '',
        ),
        HomeWidget.saveWidgetData<String>(
          _durationKey,
          duration.inSeconds.toString(),
        ),
      ]);
      await HomeWidget.updateWidget(
        name: _providerName,
        androidName: _providerName,
        qualifiedAndroidName: _qualifiedProviderName,
      );
    } catch (_) {
      // A missing platform channel in tests or an unsupported launcher must
      // never affect coffee logging in the app itself.
    }
  }

  static Future<void> clear() => sync(
        latestCoffee: null,
        duration: const Duration(hours: 4),
      );
}
