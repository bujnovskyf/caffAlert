import 'package:caff_alert/app_theme.dart';
import 'package:caff_alert/coffee_repository.dart';
import 'package:caff_alert/coffee_stats_provider.dart';
import 'package:caff_alert/l10n/app_localizations.dart';
import 'package:caff_alert/locale_controller.dart';
import 'package:caff_alert/main_shell.dart';
import 'package:caff_alert/models/coffee_log.dart';
import 'package:caff_alert/models/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Source implements CoffeeDataSource {
  final logs = <CoffeeLog>[];

  @override
  Future<CoffeeLog> addCoffee(String userId, DateTime createdAt) async {
    final log =
        CoffeeLog(id: logs.length + 1, userId: userId, createdAt: createdAt);
    logs.insert(0, log);
    return log;
  }

  @override
  Future<CoffeeLog> updateCoffeeTime(int coffeeId, DateTime createdAt) =>
      throw UnimplementedError();

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
  const homeWidget = MethodChannel('home_widget');
  const widgetClicks = EventChannel('home_widget/updates');

  /// Pumps the shell on "Android" as if the app was launched by [launchUri].
  Future<(CoffeeStatsProvider, _Source)> pumpShell(
    WidgetTester tester, {
    required String launchUri,
    DateTime? signedInAt,
  }) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(homeWidget, (call) async {
      if (call.method == 'initiallyLaunchedFromHomeWidget') return launchUri;
      return true;
    });
    messenger.setMockStreamHandler(
      widgetClicks,
      MockStreamHandler.inline(onListen: (_, __) {}),
    );
    addTearDown(() {
      messenger.setMockMethodCallHandler(homeWidget, null);
      messenger.setMockStreamHandler(widgetClicks, null);
    });

    final localeController = await LocaleController.create();
    final source = _Source();
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: source,
      now: () => DateTime.now().toUtc(),
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
          home: MainShell(
            userEmail: 'u@example.com',
            userId: 'user-1',
            signedInAt: signedInAt,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
    return (provider, source);
  }

  String tapUri(String id, DateTime at) =>
      'caffalert://widget/log?tap=$id&at=${at.millisecondsSinceEpoch}';

  testWidgets(
      'a widget coffee during onboarding finishes it, and undo removes '
      'exactly that coffee', (tester) async {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      final (provider, source) = await tester.runAsync(
        () async => pumpShell(
          tester,
          launchUri: tapUri('onboarding-tap', DateTime.now()),
        ),
      ) as (CoffeeStatsProvider, _Source);
      await tester.pumpAndSettle();

      expect(source.logs, hasLength(1));
      expect(find.text('Vítej v CaffAlertu'), findsNothing);
      expect(find.text('Zaznamenat první kávu'), findsNothing);
      expect(find.text('Káva zapsána. CAF je na 100 %.'), findsOneWidget);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('onboarding_completed_user-1'), isTrue);

      await tester.tap(find.widgetWithText(SnackBarAction, 'Vrátit'));
      await tester.pumpAndSettle();
      expect(source.logs, isEmpty);
      expect(find.text('Káva vrácena.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('a widget tap from before sign-in is never logged',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_completed_user-1': true,
    });
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      final signedInAt = DateTime.now();
      final (provider, source) = await tester.runAsync(
        () async => pumpShell(
          tester,
          launchUri: tapUri(
            'signed-out-tap',
            signedInAt.subtract(const Duration(seconds: 30)),
          ),
          signedInAt: signedInAt,
        ),
      ) as (CoffeeStatsProvider, _Source);
      await tester.pumpAndSettle();

      expect(source.logs, isEmpty);
      expect(find.text('Káva zapsána. CAF je na 100 %.'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
