import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';
import 'app_theme.dart';
import 'auth_gate.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = await LocaleController.create();

  late final AppConfig config;
  try {
    config = AppConfig.fromEnvironment();
  } on AppConfigException {
    runApp(ConfigurationErrorApp(localeController: localeController));
    return;
  }

  Future<void> startApp() async {
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
    );
    runApp(
      ChangeNotifierProvider.value(
        value: localeController,
        child: const CaffAlertApp(),
      ),
    );
  }

  if (config.sentryDsn.trim().isEmpty) {
    await startApp();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = config.sentryDsn
        ..environment = kReleaseMode ? 'production' : 'development'
        ..release = 'caffalert@1.0.0+1'
        ..debug = false
        ..sendDefaultPii = false
        ..tracesSampleRate = kReleaseMode ? 0.1 : 0.0;
    },
    appRunner: startApp,
  );
}

class CaffAlertApp extends StatelessWidget {
  const CaffAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>().locale;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AuthGate(),
    );
  }
}

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({required this.localeController, super.key});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: localeController.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) {
          final localizations = AppLocalizations.of(context);
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.settings_suggest_outlined,
                              size: 48,
                              color: AppColors.roast,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              localizations.configurationErrorTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              localizations.configurationErrorBody,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
