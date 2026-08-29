import 'package:caff_alert/app_theme.dart';
import 'package:caff_alert/auth_screen.dart';
import 'package:caff_alert/l10n/app_localizations.dart';
import 'package:caff_alert/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _testApp(Locale locale) async {
  SharedPreferences.setMockInitialValues({});
  final localeController = await LocaleController.create();

  return ChangeNotifierProvider.value(
    value: localeController,
    child: Builder(
      builder: (context) => MaterialApp(
        theme: AppTheme.light,
        locale: context.watch<LocaleController>().locale ?? locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const AuthScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('renders narrow Czech login without overflow', (tester) async {
    tester.view.physicalSize = const Size(325, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(await _testApp(const Locale('cs')));
    await tester.pumpAndSettle();

    expect(find.text('Přihlásit se'), findsWidgets);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Heslo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches between sign up and password reset in English', (
    tester,
  ) async {
    await tester.pumpWidget(await _testApp(const Locale('en')));

    await tester.tap(find.text('New here? Create an account'));
    await tester.pump();
    expect(find.text('Confirm password'), findsOneWidget);

    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pump();
    await tester.tap(find.text('Forgot your password?'));
    await tester.pump();

    expect(find.text('Reset password'), findsOneWidget);
    expect(find.text('Send reset link'), findsOneWidget);
  });

  testWidgets('switches the visible language picker', (tester) async {
    await tester.pumpWidget(await _testApp(const Locale('en')));

    await tester.tap(find.text('🇬🇧  EN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('🇨🇿  Čeština'));
    await tester.pumpAndSettle();

    expect(find.text('Přihlásit se'), findsWidgets);
    expect(find.text('🇨🇿  CZ'), findsOneWidget);
  });
}
