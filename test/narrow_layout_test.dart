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
    SharedPreferences.setMockInitialValues({
      'onboarding_completed_user-1': true,
    });
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
          home: const MainShell(
            userEmail: 'test@example.com',
            userId: 'user-1',
          ),
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
    expect(find.text('Podpora CaffAlertu'), findsOneWidget);
    expect(find.text('Napsat vývojáři'), findsOneWidget);
    expect(find.text('Jak funguje CaffAlert'), findsOneWidget);
    expect(find.text('Přečíst si o CaffAlertu'), findsOneWidget);
    expect(find.text('Disclaimer'), findsOneWidget);
    expect(find.text('Smazat účet'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('first sign-in gets a compact onboarding and can log coffee', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(325, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final localeController = await LocaleController.create();
    final provider = CoffeeStatsProvider(
      userId: 'new-user',
      repository: _NarrowLayoutSource([]),
      now: () => DateTime.utc(2026, 8, 28, 12),
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
          home: const MainShell(
            userEmail: 'new@example.com',
            userId: 'new-user',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vítej v CaffAlertu'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Pokračovat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pokračovat'));
    await tester.pumpAndSettle();
    expect(find.text('Čtyřhodinový protokol'), findsOneWidget);
    await tester.tap(find.text('Zdroj'));
    await tester.pumpAndSettle();
    expect(find.text('I made it up.'), findsOneWidget);
    await tester.tap(find.text('Skrýt'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zaznamenat první kávu'));
    await tester.pumpAndSettle();
    expect(provider.logs, hasLength(1));
    expect(find.text('Vítej v CaffAlertu'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });
}
