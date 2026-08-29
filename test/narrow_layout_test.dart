import 'package:caff_alert/app_theme.dart';
import 'package:caff_alert/coffee_repository.dart';
import 'package:caff_alert/coffee_stats_provider.dart';
import 'package:caff_alert/l10n/app_localizations.dart';
import 'package:caff_alert/locale_controller.dart';
import 'package:caff_alert/main_shell.dart';
import 'package:caff_alert/models/coffee_log.dart';
import 'package:caff_alert/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NarrowLayoutSource implements CoffeeDataSource {
  _NarrowLayoutSource(this.logs);

  final List<CoffeeLog> logs;

  @override
  Future<CoffeeLog> addCoffee(String userId, DateTime createdAt) async {
    final log = CoffeeLog(
      id: logs.length + 1,
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
      id: logs[index].id,
      userId: logs[index].userId,
      createdAt: createdAt,
    );
    logs[index] = updated;
    return updated;
  }

  @override
  Future<CoffeeLog?> deleteCoffee(int coffeeId) async {
    final index = logs.indexWhere((log) => log.id == coffeeId);
    if (index == -1) return null;
    return logs.removeAt(index);
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
  testWidgets('main shell, timer, and statistics fit a 325px screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(325, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.utc(2026, 8, 28, 12);
    SharedPreferences.setMockInitialValues({});
    final localeController = await LocaleController.create();
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: _NarrowLayoutSource([
        CoffeeLog(id: 1, userId: 'user-1', createdAt: now),
      ]),
      now: () => now,
    );
    await provider.refresh();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider.value(value: localeController),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const MainShell(userEmail: 'test@example.com'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('CAF úroveň na nule za'), findsOneWidget);
    expect(find.text('Měl/a jsem kávu'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Statistiky'));
    await tester.pump();
    expect(find.text('Káv dnes'), findsOneWidget);
    expect(find.text('Kávy z posledních 24 hodin'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pump();
    expect(find.text('Ohodnotit CaffAlert'), findsOneWidget);
    expect(find.text('Kontakt a nápady'), findsOneWidget);
    expect(find.text('Napsat vývojáři'), findsOneWidget);
    expect(find.text('O CaffAlertu'), findsOneWidget);
    expect(find.text('Otevřít CAF emergency brief'), findsOneWidget);
    expect(find.text('Smazat účet'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });
}
