import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._(this._preferences, this._locale);

  static const _preferenceKey = 'preferred_locale';

  static Future<LocaleController> create() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_preferenceKey);
    final locale = languageCode == null ? null : Locale(languageCode);
    return LocaleController._(preferences, locale);
  }

  final SharedPreferences _preferences;
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> setLocale(Locale? locale) async {
    if (_locale?.languageCode == locale?.languageCode) return;
    _locale = locale;
    if (locale == null) {
      await _preferences.remove(_preferenceKey);
    } else {
      await _preferences.setString(_preferenceKey, locale.languageCode);
    }
    notifyListeners();
  }
}
