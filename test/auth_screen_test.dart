import 'package:caff_alert/app_theme.dart';
import 'package:caff_alert/auth_screen.dart';
import 'package:caff_alert/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testApp(Locale locale) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: const AuthScreen(),
  );
}

void main() {
  testWidgets('renders narrow Czech login without overflow', (tester) async {
    tester.view.physicalSize = const Size(325, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(const Locale('cs')));
    await tester.pumpAndSettle();

    expect(find.text('Přihlásit se'), findsWidgets);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Heslo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches between sign up and password reset in English', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const Locale('en')));

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
}
