import 'models/coffee_log.dart';

enum CoffeeStatus { noCoffeeToday, calm, coffeeShift, espressoDrive, legend }

abstract final class CoffeeMetrics {
  static const _defaultDurationSeconds = 4 * 60 * 60;
  static const _configuredDurationSeconds = int.fromEnvironment(
    'CAFF_LEVEL_DURATION_SECONDS',
    defaultValue: _defaultDurationSeconds,
  );
  static final duration = Duration(
    seconds: _configuredDurationSeconds > 0
        ? _configuredDurationSeconds
        : _defaultDurationSeconds,
  );

  static CoffeeLog? latest(List<CoffeeLog> logs) =>
      logs.isEmpty ? null : logs.first;

  static Duration remaining(List<CoffeeLog> logs, DateTime now) {
    final latestLog = latest(logs);
    if (latestLog == null) return Duration.zero;
    final elapsed = now.toUtc().difference(latestLog.createdAt);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static int caffLevelPercent(List<CoffeeLog> logs, DateTime now) {
    final remainingDuration = remaining(logs, now);
    return (remainingDuration.inMilliseconds / duration.inMilliseconds * 100)
        .round()
        .clamp(0, 100)
        .toInt();
  }

  static CoffeeStatus statusForDailyCoffees(int count) {
    if (count == 0) return CoffeeStatus.noCoffeeToday;
    if (count <= 3) return CoffeeStatus.calm;
    if (count <= 5) return CoffeeStatus.coffeeShift;
    if (count <= 9) return CoffeeStatus.espressoDrive;
    return CoffeeStatus.legend;
  }

  static List<CoffeeLog> today(List<CoffeeLog> logs, DateTime now) {
    final localNow = now.toLocal();
    return logs.where((log) {
      final date = log.createdAt.toLocal();
      return date.year == localNow.year &&
          date.month == localNow.month &&
          date.day == localNow.day;
    }).toList(growable: false);
  }

  static int monthlyCount(List<CoffeeLog> logs, DateTime now) {
    final localNow = now.toLocal();
    return logs.where((log) {
      final date = log.createdAt.toLocal();
      return date.year == localNow.year && date.month == localNow.month;
    }).length;
  }

  static CoffeeLog? firstToday(List<CoffeeLog> logs, DateTime now) {
    final values = today(logs, now);
    if (values.isEmpty) return null;
    return values.reduce(
      (first, next) => first.createdAt.isBefore(next.createdAt) ? first : next,
    );
  }

  static CoffeeLog? lastToday(List<CoffeeLog> logs, DateTime now) {
    final values = today(logs, now);
    if (values.isEmpty) return null;
    return values.reduce(
      (last, next) => last.createdAt.isAfter(next.createdAt) ? last : next,
    );
  }

  static Duration? averageIntervalToday(
    List<CoffeeLog> logs,
    DateTime now,
  ) {
    final values = today(logs, now).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (values.length < 2) return null;

    var totalSeconds = 0;
    for (var index = 1; index < values.length; index++) {
      totalSeconds += values[index]
          .createdAt
          .difference(values[index - 1].createdAt)
          .inSeconds;
    }
    return Duration(seconds: totalSeconds ~/ (values.length - 1));
  }
}
