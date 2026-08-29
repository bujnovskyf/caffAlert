import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CaffAlert'**
  String get appTitle;

  /// No description provided for @configurationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'CaffAlert needs configuration'**
  String get configurationErrorTitle;

  /// No description provided for @configurationErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Add SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY, then rebuild the app.'**
  String get configurationErrorBody;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t let your caffeine level hit zero.'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow your caffeine rhythm. When your CAF level drops, it is time to top it up.'**
  String get authWelcomeSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @switchToSignUp.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get switchToSignUp;

  /// No description provided for @switchToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToSignIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a secure reset link.'**
  String get resetPasswordBody;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Please try again.'**
  String get authGenericError;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get invalidCredentials;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email before signing in.'**
  String get emailNotConfirmed;

  /// No description provided for @accountExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get accountExists;

  /// No description provided for @rateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment and try again.'**
  String get rateLimited;

  /// No description provided for @confirmationSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get confirmationSentTitle;

  /// No description provided for @confirmationSentBody.
  ///
  /// In en, this message translates to:
  /// **'We sent you a confirmation link. Open it, then return here to sign in.'**
  String get confirmationSentBody;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'The reset link is on its way.'**
  String get resetLinkSent;

  /// No description provided for @updatePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get updatePasswordTitle;

  /// No description provided for @updatePasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Your reset link was accepted. Set a new password to continue.'**
  String get updatePasswordBody;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your password was updated.'**
  String get passwordUpdated;

  /// No description provided for @timerNavigation.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerNavigation;

  /// No description provided for @statsNavigation.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsNavigation;

  /// No description provided for @settingsNavigation.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsNavigation;

  /// No description provided for @timerEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR COFFEE RHYTHM'**
  String get timerEyebrow;

  /// No description provided for @nextCoffeeIn.
  ///
  /// In en, this message translates to:
  /// **'CAF level reaches zero in'**
  String get nextCoffeeIn;

  /// No description provided for @coffeeReady.
  ///
  /// In en, this message translates to:
  /// **'CAF level is at zero'**
  String get coffeeReady;

  /// No description provided for @coffeeReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time to brew a coffee.'**
  String get coffeeReadySubtitle;

  /// No description provided for @coffeeLowLevelWarning.
  ///
  /// In en, this message translates to:
  /// **'Heads up, your CAF level is nearing zero.'**
  String get coffeeLowLevelWarning;

  /// No description provided for @caffLevel.
  ///
  /// In en, this message translates to:
  /// **'CAF level'**
  String get caffLevel;

  /// No description provided for @caffLevelValue.
  ///
  /// In en, this message translates to:
  /// **'CAF level: {value}%'**
  String caffLevelValue(int value);

  /// No description provided for @logCoffee.
  ///
  /// In en, this message translates to:
  /// **'I had a coffee'**
  String get logCoffee;

  /// No description provided for @coffeeLogged.
  ///
  /// In en, this message translates to:
  /// **'CAF level replenished.'**
  String get coffeeLogged;

  /// No description provided for @lastCoffee.
  ///
  /// In en, this message translates to:
  /// **'Last coffee'**
  String get lastCoffee;

  /// No description provided for @editRecentCoffees.
  ///
  /// In en, this message translates to:
  /// **'Edit recent coffees'**
  String get editRecentCoffees;

  /// No description provided for @editRecentCoffeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Coffees from the last 24 hours'**
  String get editRecentCoffeesTitle;

  /// No description provided for @editCoffeeTimeAction.
  ///
  /// In en, this message translates to:
  /// **'Edit coffee time'**
  String get editCoffeeTimeAction;

  /// No description provided for @editCoffeeTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'When did you have it?'**
  String get editCoffeeTimeTitle;

  /// No description provided for @editCoffeeTimeOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Coffee time must be within the last 24 hours.'**
  String get editCoffeeTimeOutOfRange;

  /// No description provided for @coffeeTimeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Coffee time updated.'**
  String get coffeeTimeUpdated;

  /// No description provided for @noCoffeeYet.
  ///
  /// In en, this message translates to:
  /// **'No coffee logged yet'**
  String get noCoffeeYet;

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed.'**
  String get actionFailed;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your caffeine at a glance'**
  String get statsTitle;

  /// No description provided for @statsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A simple view of your caffeine rhythm.'**
  String get statsSubtitle;

  /// No description provided for @welcomeName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String welcomeName(String name);

  /// No description provided for @coffeesToday.
  ///
  /// In en, this message translates to:
  /// **'Coffees today'**
  String get coffeesToday;

  /// No description provided for @coffeeStatus.
  ///
  /// In en, this message translates to:
  /// **'Coffee status'**
  String get coffeeStatus;

  /// No description provided for @coffeeStatusNoCoffeeToday.
  ///
  /// In en, this message translates to:
  /// **'No coffee today'**
  String get coffeeStatusNoCoffeeToday;

  /// No description provided for @coffeeStatusCalm.
  ///
  /// In en, this message translates to:
  /// **'All good'**
  String get coffeeStatusCalm;

  /// No description provided for @coffeeStatusCoffeeShift.
  ///
  /// In en, this message translates to:
  /// **'Coffee shift'**
  String get coffeeStatusCoffeeShift;

  /// No description provided for @coffeeStatusEspressoDrive.
  ///
  /// In en, this message translates to:
  /// **'Espresso drive'**
  String get coffeeStatusEspressoDrive;

  /// No description provided for @coffeeStatusLegend.
  ///
  /// In en, this message translates to:
  /// **'Coffee legend'**
  String get coffeeStatusLegend;

  /// No description provided for @firstCoffeeToday.
  ///
  /// In en, this message translates to:
  /// **'First today'**
  String get firstCoffeeToday;

  /// No description provided for @lastCoffeeToday.
  ///
  /// In en, this message translates to:
  /// **'Last today'**
  String get lastCoffeeToday;

  /// No description provided for @averageIntervalToday.
  ///
  /// In en, this message translates to:
  /// **'Average interval'**
  String get averageIntervalToday;

  /// No description provided for @coffeesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get coffeesThisMonth;

  /// No description provided for @totalCoffees.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get totalCoffees;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noData;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get notAvailable;

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutesValue(String value);

  /// No description provided for @removeLastCoffee.
  ///
  /// In en, this message translates to:
  /// **'Remove latest coffee'**
  String get removeLastCoffee;

  /// No description provided for @removeCoffeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove latest coffee?'**
  String get removeCoffeeTitle;

  /// No description provided for @removeCoffeeBody.
  ///
  /// In en, this message translates to:
  /// **'The timer and statistics will return to the previous coffee on all your devices.'**
  String get removeCoffeeBody;

  /// No description provided for @removeCoffeeEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this entry?'**
  String get removeCoffeeEntryTitle;

  /// No description provided for @removeCoffeeEntryBody.
  ///
  /// In en, this message translates to:
  /// **'This coffee will disappear from your overview and CAF level on all devices.'**
  String get removeCoffeeEntryBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSection;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameLabel;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, up to 80 characters'**
  String get displayNameHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get systemLanguage;

  /// No description provided for @czech.
  ///
  /// In en, this message translates to:
  /// **'Čeština'**
  String get czech;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get signedInAs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate CaffAlert'**
  String get rateApp;

  /// No description provided for @rateAppHint.
  ///
  /// In en, this message translates to:
  /// **'Enjoying CaffAlert? Leave a rating on Google Play.'**
  String get rateAppHint;

  /// No description provided for @couldNotOpenStore.
  ///
  /// In en, this message translates to:
  /// **'We could not open Google Play.'**
  String get couldNotOpenStore;

  /// No description provided for @feedbackSection.
  ///
  /// In en, this message translates to:
  /// **'Contact & ideas'**
  String get feedbackSection;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Have an idea, found a problem, or want to improve something? Send the developer a note.'**
  String get feedbackHint;

  /// No description provided for @contactDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Contact the developer'**
  String get contactDeveloper;

  /// No description provided for @couldNotOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'We could not open your email app.'**
  String get couldNotOpenEmail;

  /// No description provided for @aboutCaffAlertSection.
  ///
  /// In en, this message translates to:
  /// **'How CaffAlert works'**
  String get aboutCaffAlertSection;

  /// No description provided for @aboutCaffAlertHint.
  ///
  /// In en, this message translates to:
  /// **'Keep your caffeine rhythm and CAF level in view throughout the day.'**
  String get aboutCaffAlertHint;

  /// No description provided for @caffEmergencyBrief.
  ///
  /// In en, this message translates to:
  /// **'Read about CaffAlert'**
  String get caffEmergencyBrief;

  /// No description provided for @caffEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'About CaffAlert'**
  String get caffEmergencyTitle;

  /// No description provided for @caffEmergencyBody.
  ///
  /// In en, this message translates to:
  /// **'CaffAlert is a tool for keeping your caffeine rhythm in view throughout the day. Log a coffee, an energy drink, or another caffeinated drink — every log replenishes your CAF level and joins your history.\n\nCAF level then gradually drops over four hours. At a glance, you can see when you last logged something, how often you return to caffeine, and when the system starts dramatically asking for attention.\n\nCaffAlert is neither a diet nor a limiter. It is a simple overview that keeps your caffeine rhythm visible. Stay caffeinated.'**
  String get caffEmergencyBody;

  /// No description provided for @appDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get appDisclaimerTitle;

  /// No description provided for @appDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'CAF level is a fictional game indicator based on the time since a log. It does not measure caffeine in your body and is not health advice or a guide to how much caffeine to drink.'**
  String get appDisclaimerBody;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes your account, profile, and all coffee logs.'**
  String get deleteAccountHint;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account and all data?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Your profile, coffee logs, and sign-in account will be deleted.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountConfirm;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get termsOfUse;

  /// No description provided for @deleteAccountWeb.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountWeb;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading your coffee data…'**
  String get loadingData;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'We could not load your data.'**
  String get errorLoadingData;

  /// No description provided for @emptyStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first caffeine dose will appear here'**
  String get emptyStatsTitle;

  /// No description provided for @emptyStatsBody.
  ///
  /// In en, this message translates to:
  /// **'Log a dose on the timer screen to start building your overview.'**
  String get emptyStatsBody;

  /// No description provided for @onboardingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CAF SYSTEM // START'**
  String get onboardingEyebrow;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CaffAlert'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your day moves fast. CaffAlert helps you keep your caffeine rhythm in view.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Every log counts'**
  String get onboardingLogTitle;

  /// No description provided for @onboardingLogBody.
  ///
  /// In en, this message translates to:
  /// **'Log a coffee, an energy drink, or another caffeinated drink. Each log replenishes your CAF level.'**
  String get onboardingLogBody;

  /// No description provided for @onboardingTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep CAF level in sight'**
  String get onboardingTrackTitle;

  /// No description provided for @onboardingTrackBody.
  ///
  /// In en, this message translates to:
  /// **'CAF level gradually drops. When it gets low, CaffAlert will dramatically remind you that the system is losing momentum.'**
  String get onboardingTrackBody;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingNext;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Log your first coffee'**
  String get onboardingStart;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
