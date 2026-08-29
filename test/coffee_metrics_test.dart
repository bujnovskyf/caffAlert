import 'package:caff_alert/coffee_metrics.dart';
import 'package:caff_alert/models/coffee_log.dart';
import 'package:flutter_test/flutter_test.dart';

CoffeeLog _log(int id, DateTime localTime) {
  return CoffeeLog(
    id: id,
    userId: 'user-1',
    createdAt: localTime.toUtc(),
  );
}

void main() {
  group('CoffeeMetrics timer', () {
    final now = DateTime(2026, 8, 28, 12);

    test('is ready when no coffee exists', () {
      expect(CoffeeMetrics.remaining(const [], now), Duration.zero);
    });

    test('counts down four hours from latest coffee', () {
      final logs = [_log(1, now.subtract(const Duration(hours: 1)))];

      expect(
        CoffeeMetrics.remaining(logs, now),
        const Duration(hours: 3),
      );
      expect(CoffeeMetrics.caffLevelPercent(logs, now), 75);
    });

    test('stays ready after four hours', () {
      final logs = [_log(1, now.subtract(const Duration(hours: 5)))];

      expect(CoffeeMetrics.remaining(logs, now), Duration.zero);
    });

    test('returns to previous coffee after latest is removed', () {
      final latest = _log(2, now.subtract(const Duration(minutes: 30)));
      final previous = _log(1, now.subtract(const Duration(hours: 2)));

      expect(
        CoffeeMetrics.remaining([latest, previous], now),
        const Duration(hours: 3, minutes: 30),
      );
      expect(
        CoffeeMetrics.remaining([previous], now),
        const Duration(hours: 2),
      );
    });
  });

  group('CoffeeMetrics statistics', () {
    final now = DateTime(2026, 8, 28, 18);
    final logs = [
      _log(4, DateTime(2026, 8, 28, 15)),
      _log(3, DateTime(2026, 8, 28, 11)),
      _log(2, DateTime(2026, 8, 28, 9)),
      _log(1, DateTime(2026, 8, 27, 8)),
    ];

    test('calculates daily and monthly totals in local time', () {
      expect(CoffeeMetrics.today(logs, now), hasLength(3));
      expect(CoffeeMetrics.monthlyCount(logs, now), 4);
    });

    test('finds first, last, and average interval for today', () {
      expect(CoffeeMetrics.firstToday(logs, now)?.id, 2);
      expect(CoffeeMetrics.lastToday(logs, now)?.id, 4);
      expect(
        CoffeeMetrics.averageIntervalToday(logs, now),
        const Duration(hours: 3),
      );
    });
  });

  group('CoffeeMetrics coffee status', () {
    test('uses playful daily status thresholds', () {
      expect(
          CoffeeMetrics.statusForDailyCoffees(0), CoffeeStatus.noCoffeeToday);
      expect(CoffeeMetrics.statusForDailyCoffees(3), CoffeeStatus.calm);
      expect(CoffeeMetrics.statusForDailyCoffees(4), CoffeeStatus.coffeeShift);
      expect(
        CoffeeMetrics.statusForDailyCoffees(6),
        CoffeeStatus.espressoDrive,
      );
      expect(CoffeeMetrics.statusForDailyCoffees(10), CoffeeStatus.legend);
    });
  });
}
