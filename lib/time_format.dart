import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Clock times, shown the same way in the app and in the Android widget
/// (`CaffAlertWidgetProvider.formatEndTime`): Czech always uses the 24-hour
/// clock, other languages follow the system's 24-hour switch.
abstract final class AppTimeFormat {
  static bool uses24Hour(String locale,
          {required bool alwaysUse24HourFormat}) =>
      alwaysUse24HourFormat || locale.toLowerCase().startsWith('cs');

  /// `14:30` / `2:30 PM` (Czech `8:05`).
  static DateFormat time(String locale,
          {required bool alwaysUse24HourFormat}) =>
      uses24Hour(locale, alwaysUse24HourFormat: alwaysUse24HourFormat)
          ? DateFormat.Hm(locale)
          : DateFormat.jm(locale);

  /// [date] followed by the time, e.g. `14. 11. 8:05` / `Nov 14 2:30 PM`.
  static DateFormat withTime(
    DateFormat date,
    String locale, {
    required bool alwaysUse24HourFormat,
  }) =>
      uses24Hour(locale, alwaysUse24HourFormat: alwaysUse24HourFormat)
          ? date.add_Hm()
          : date.add_jm();

  /// The system 24-hour setting (Android); false where it is unknown (web).
  static bool alwaysUse24HourFormatOf(BuildContext context) =>
      MediaQuery.maybeAlwaysUse24HourFormatOf(context) ?? false;
}
