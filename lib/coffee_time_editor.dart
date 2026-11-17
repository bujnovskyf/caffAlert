import 'package:flutter/material.dart';

import 'coffee_stats_provider.dart';
import 'l10n/app_localizations.dart';
import 'models/coffee_log.dart';
import 'time_format.dart';

/// Changing the time of a logged coffee needs only a time: coffees are
/// editable for [CoffeeStatsProvider.coffeeEditWindow] (24 hours), so every
/// clock time maps to exactly one moment in that window.
class CoffeeTimeEditor {
  const CoffeeTimeEditor._();

  /// The moment [time] refers to: today when it is not later than [now],
  /// otherwise yesterday (local time).
  static DateTime resolve(TimeOfDay time, DateTime now) {
    final localNow = now.toLocal();
    final today = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
      time.hour,
      time.minute,
    );
    if (!today.isAfter(localNow)) return today;
    return DateTime(
      localNow.year,
      localNow.month,
      localNow.day - 1,
      time.hour,
      time.minute,
    );
  }

  /// Asks for a new time of [coffee] and saves it, with a snackbar either way.
  static Future<void> edit(
    BuildContext context,
    CoffeeStatsProvider state,
    CoffeeLog coffee,
  ) async {
    if (!state.canEditCoffee(coffee)) return;

    final localizations = AppLocalizations.of(context);
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(coffee.createdAt.toLocal()),
      helpText: localizations.editCoffeeTimeTitle,
    );
    if (selectedTime == null || !context.mounted) return;

    final now = state.now.toLocal();
    final correctedTime = resolve(selectedTime, now);
    final success = await state.updateCoffeeTime(coffee, correctedTime);
    if (!context.mounted) return;

    final time = AppTimeFormat.time(
      Localizations.localeOf(context).toLanguageTag(),
      alwaysUse24HourFormat: AppTimeFormat.alwaysUse24HourFormatOf(context),
    ).format(correctedTime);
    final message = !success
        ? localizations.actionFailed
        : DateUtils.isSameDay(correctedTime, now)
            ? localizations.coffeeTimeUpdatedToday(time)
            : localizations.coffeeTimeUpdatedYesterday(time);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
