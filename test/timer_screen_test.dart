import 'package:caff_alert/app_theme.dart';
import 'package:caff_alert/coffee_repository.dart';
import 'package:caff_alert/coffee_stats_provider.dart';
import 'package:caff_alert/coffee_time_editor.dart';
import 'package:caff_alert/l10n/app_localizations.dart';
import 'package:caff_alert/models/coffee_log.dart';
import 'package:caff_alert/models/profile.dart';
import 'package:caff_alert/timer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

class _Source implements CoffeeDataSource {
  _Source(this.logs);

  final List<CoffeeLog> logs;

  @override
  Future<CoffeeLog> addCoffee(String userId, DateTime createdAt) async {
    final log =
        CoffeeLog(id: logs.length + 10, userId: userId, createdAt: createdAt);
    logs.insert(0, log);
    return log;
  }

  @override
  Future<CoffeeLog> updateCoffeeTime(int coffeeId, DateTime createdAt) async {
    final index = logs.indexWhere((log) => log.id == coffeeId);
    final updated = CoffeeLog(
        id: coffeeId, userId: logs[index].userId, createdAt: createdAt);
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
  Future<List<CoffeeLog>> fetchLogs(String userId) async => List.of(logs);

  @override
  Future<Profile?> fetchProfile(String userId) async => null;

  @override
  Future<void> saveDisplayName(String userId, String? displayName) async {}

  @override
  void subscribeToLogs(String userId, Future<void> Function() onChange) {}
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('cs');
    await initializeDateFormatting('en');
  });

  group('Czech and English plurals', () {
    final cs = lookupAppLocalizations(const Locale('cs'));
    final en = lookupAppLocalizations(const Locale('en'));

    test('today count uses 1 káva / 2–4 kávy / 5+ káv', () {
      expect(cs.coffeesTodayCount(0), 'Dnes zatím bez kávy');
      expect(cs.coffeesTodayCount(1), 'Dnes 1 káva');
      expect(cs.coffeesTodayCount(2), 'Dnes 2 kávy');
      expect(cs.coffeesTodayCount(4), 'Dnes 4 kávy');
      expect(cs.coffeesTodayCount(5), 'Dnes 5 káv');
      expect(cs.coffeesTodayCount(11), 'Dnes 11 káv');
      expect(en.coffeesTodayCount(0), 'No coffee yet today');
      expect(en.coffeesTodayCount(1), '1 coffee today');
      expect(en.coffeesTodayCount(3), '3 coffees today');
    });
  });

  group('status line under the gauge', () {
    final cs = lookupAppLocalizations(const Locale('cs'));
    CoffeeLog at(DateTime local) =>
        CoffeeLog(id: 1, userId: 'u', createdAt: local.toUtc());

    test('shows when CAF reaches zero today', () {
      final coffee = at(DateTime(2026, 11, 14, 10, 35));
      expect(
        TimerScreen.statusLine(
          localizations: cs,
          locale: 'cs',
          now: DateTime(2026, 11, 14, 11),
          latestCoffee: coffee,
          zeroAt: coffee.createdAt.add(const Duration(hours: 4)),
        ),
        'CAF na nule v 14:35',
      );
    });

    test('says tomorrow when the countdown crosses midnight', () {
      final coffee = at(DateTime(2026, 11, 14, 22, 10));
      expect(
        TimerScreen.statusLine(
          localizations: cs,
          locale: 'cs',
          now: DateTime(2026, 11, 14, 23),
          latestCoffee: coffee,
          zeroAt: coffee.createdAt.add(const Duration(hours: 4)),
        ),
        'CAF na nule zítra v 2:10',
      );
    });

    test('after zero shows the time of the latest coffee', () {
      final coffee = at(DateTime(2026, 11, 14, 8, 5));
      expect(
        TimerScreen.statusLine(
          localizations: cs,
          locale: 'cs',
          now: DateTime(2026, 11, 14, 13),
          latestCoffee: coffee,
          zeroAt: coffee.createdAt.add(const Duration(hours: 4)),
        ),
        'Poslední káva v 8:05',
      );
    });

    test('English follows the system 24-hour switch, Czech is always 24 h', () {
      final en = lookupAppLocalizations(const Locale('en'));
      final coffee = at(DateTime(2026, 11, 14, 10, 30));
      String? line(AppLocalizations l10n, String locale, bool use24h) =>
          TimerScreen.statusLine(
            localizations: l10n,
            locale: locale,
            now: DateTime(2026, 11, 14, 11),
            latestCoffee: coffee,
            zeroAt: coffee.createdAt.add(const Duration(hours: 4)),
            alwaysUse24HourFormat: use24h,
          );
      expect(line(en, 'en', false), 'CAF hits zero at 2:30\u202fPM');
      expect(line(en, 'en', true), 'CAF hits zero at 14:30');
      expect(line(cs, 'cs', false), 'CAF na nule v 14:30');
    });

    test('nothing without a coffee', () {
      expect(
        TimerScreen.statusLine(
          localizations: cs,
          locale: 'cs',
          now: DateTime(2026, 11, 14),
          latestCoffee: null,
          zeroAt: null,
        ),
        isNull,
      );
    });

    test('gauge mode thresholds', () {
      CafGaugeMode mode(bool has, bool ready, int percent) =>
          TimerScreen.modeFor(hasCoffee: has, isReady: ready, percent: percent);
      expect(mode(false, true, 0), CafGaugeMode.empty);
      expect(mode(true, true, 0), CafGaugeMode.zero);
      expect(mode(true, false, 20), CafGaugeMode.low);
      expect(mode(true, false, 21), CafGaugeMode.running);
    });
  });

  group('today timeline', () {
    CoffeeLog at(int id, DateTime local) =>
        CoffeeLog(id: id, userId: 'u', createdAt: local.toUtc());
    const fourHours = Duration(hours: 4);

    test('a CAF window from yesterday that runs past midnight carries over',
        () {
      final now = DateTime(2026, 11, 15, 1);
      final logs = [
        at(2, DateTime(2026, 11, 14, 22, 10)),
        at(1, DateTime(2026, 11, 14, 9)),
      ];
      expect(
        TimerScreen.carryOverEnd(logs, now, fourHours),
        DateTime(2026, 11, 15, 2, 10),
      );
      expect(
        DayTimelinePainter.startHourFor(
          const [],
          carryOverEnd: DateTime(2026, 11, 15, 2, 10),
        ),
        0,
      );
    });

    test('no carry-over when yesterday ended before midnight', () {
      final logs = [at(1, DateTime(2026, 11, 14, 19, 30))];
      expect(
        TimerScreen.carryOverEnd(logs, DateTime(2026, 11, 15, 8), fourHours),
        isNull,
      );
      expect(DayTimelinePainter.startHourFor([DateTime(2026, 11, 15, 7)]), 6);
      expect(DayTimelinePainter.startHourFor([DateTime(2026, 11, 15, 5)]), 5);
    });

    test('a coffee of today is not a carry-over', () {
      final logs = [at(1, DateTime(2026, 11, 15, 0, 30))];
      expect(
        TimerScreen.carryOverEnd(logs, DateTime(2026, 11, 15, 1), fourHours),
        isNull,
      );
    });
  });

  testWidgets('a carried-over window shows the timeline without a coffee today',
      (tester) async {
    final now = DateTime(2026, 11, 15, 1).toUtc();
    final provider = CoffeeStatsProvider(
      userId: 'u',
      repository: _Source([
        CoffeeLog(
          id: 1,
          userId: 'u',
          createdAt: DateTime(2026, 11, 14, 22, 10).toUtc(),
        ),
      ]),
      now: () => now,
    );
    await provider.refresh();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const TimerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dnes zatím bez kávy'), findsOneWidget);
    expect(find.text('CAF na nule v 2:10'), findsOneWidget);
    expect(
      find.text('První dnešní káva se objeví tady na časové ose.'),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint &&
            widget.painter is DayTimelinePainter &&
            (widget.painter! as DayTimelinePainter).coffees.isEmpty &&
            (widget.painter! as DayTimelinePainter).carryOverEnd != null,
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  group('changing the time of a coffee', () {
    test('a clock time not later than now is today', () {
      final now = DateTime(2026, 11, 14, 9, 30);
      expect(
        CoffeeTimeEditor.resolve(const TimeOfDay(hour: 9, minute: 30), now),
        DateTime(2026, 11, 14, 9, 30),
      );
      expect(
        CoffeeTimeEditor.resolve(const TimeOfDay(hour: 0, minute: 5), now),
        DateTime(2026, 11, 14, 0, 5),
      );
    });

    test('a clock time later than now is yesterday, across a month', () {
      final now = DateTime(2026, 12, 1, 9, 30);
      expect(
        CoffeeTimeEditor.resolve(const TimeOfDay(hour: 9, minute: 31), now),
        DateTime(2026, 11, 30, 9, 31),
      );
      expect(
        CoffeeTimeEditor.resolve(const TimeOfDay(hour: 23, minute: 40), now),
        DateTime(2026, 11, 30, 23, 40),
      );
    });
  });

  Future<CoffeeStatsProvider> pumpTimer(
    WidgetTester tester,
    _Source source,
    DateTime now,
  ) async {
    final provider = CoffeeStatsProvider(
      userId: 'u',
      repository: source,
      now: () => now,
    );
    await provider.refresh();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const TimerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return provider;
  }

  testWidgets('the last coffee can be moved back to yesterday', (tester) async {
    final now = DateTime(2026, 11, 14, 9);
    final source = _Source([
      CoffeeLog(id: 1, userId: 'u', createdAt: DateTime(2026, 11, 14, 8)),
    ]);
    final provider = await pumpTimer(tester, source, now);

    await tester.tap(find.text('Upravit čas'));
    await tester.pumpAndSettle();
    expect(find.text('Kdy byla káva?'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '10');
    await tester.enterText(fields.at(1), '15');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(
        source.logs.single.createdAt.toLocal(), DateTime(2026, 11, 13, 10, 15));
    expect(find.text('Káva přesunutá na včera 10:15.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('no time change for a coffee older than 24 hours',
      (tester) async {
    final now = DateTime(2026, 11, 14, 9);
    final source = _Source([
      CoffeeLog(id: 1, userId: 'u', createdAt: DateTime(2026, 11, 13, 8)),
    ]);
    final provider = await pumpTimer(tester, source, now);

    expect(find.text('Upravit čas'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('log coffee shows an undo that removes exactly that coffee',
      (tester) async {
    final now = DateTime.utc(2026, 11, 14, 9);
    final source = _Source([
      CoffeeLog(
        id: 1,
        userId: 'u',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ]);
    final provider = CoffeeStatsProvider(
      userId: 'u',
      repository: source,
      now: () => now,
    );
    await provider.refresh();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const TimerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('CAF na nule'), findsOneWidget);
    expect(find.textContaining('Poslední káva'), findsOneWidget);

    await tester.tap(find.text('Zapsat kávu'));
    await tester.pumpAndSettle();
    expect(source.logs, hasLength(2));
    expect(find.text('Káva zapsána. CAF je na 100 %.'), findsOneWidget);
    expect(find.textContaining('CAF na nule v'), findsOneWidget);
    expect(find.text('Odstranit poslední kávu'), findsNothing);

    await tester.tap(find.text('Vrátit'));
    await tester.pumpAndSettle();
    expect(source.logs.map((log) => log.id), [1]);
    expect(find.text('Káva vrácena.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('empty state explains what to do', (tester) async {
    final provider = CoffeeStatsProvider(
      userId: 'u',
      repository: _Source([]),
      now: () => DateTime.utc(2026, 11, 14, 9),
    );
    await provider.refresh();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const TimerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Zatím žádná káva'), findsOneWidget);
    expect(
      find.text('Zapiš kávu a spustí se čtyřhodinový CAF odpočet.'),
      findsOneWidget,
    );
    expect(find.text('Dnes zatím bez kávy'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });
}
