// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CaffAlert';

  @override
  String get configurationErrorTitle => 'CaffAlert needs configuration';

  @override
  String get configurationErrorBody =>
      'Add SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY, then rebuild the app.';

  @override
  String get authWelcomeTitle => 'Your coffee day, playful and clear.';

  @override
  String get authWelcomeSubtitle =>
      'Log a coffee and watch a playful CAF countdown. It is a game indicator, not a caffeine measurement.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get switchToSignUp => 'New here? Create an account';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordBody =>
      'Enter your email and we will send you a secure reset link.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get emailRequired => 'Enter your email.';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get passwordRequired => 'Enter your password.';

  @override
  String get passwordTooShort => 'Use at least 8 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authGenericError => 'That did not work. Please try again.';

  @override
  String get invalidCredentials => 'The email or password is incorrect.';

  @override
  String get emailNotConfirmed => 'Confirm your email before signing in.';

  @override
  String get accountExists => 'An account with this email already exists.';

  @override
  String get rateLimited => 'Too many attempts. Wait a moment and try again.';

  @override
  String get confirmationSentTitle => 'Check your inbox';

  @override
  String get confirmationSentBody =>
      'We sent you a confirmation link. Open it, then return here to sign in.';

  @override
  String get resetLinkSent => 'The reset link is on its way.';

  @override
  String get updatePasswordTitle => 'Choose a new password';

  @override
  String get updatePasswordBody =>
      'Your reset link was accepted. Set a new password to continue.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get savePassword => 'Save password';

  @override
  String get passwordUpdated => 'Your password was updated.';

  @override
  String get timerNavigation => 'Timer';

  @override
  String get statsNavigation => 'Stats';

  @override
  String get settingsNavigation => 'Settings';

  @override
  String get timerEyebrow => 'YOUR COFFEE RHYTHM';

  @override
  String get coffeeReady => 'CAF level is at zero';

  @override
  String get coffeeReadySubtitle => 'Coffee, water, or a break? Your call.';

  @override
  String get caffLevel => 'CAF level';

  @override
  String caffLevelValue(int value) {
    return 'CAF level: $value%';
  }

  @override
  String get logCoffee => 'Log a coffee';

  @override
  String get coffeeLogged => 'Coffee logged. CAF is back at 100%.';

  @override
  String get lastCoffee => 'Last coffee';

  @override
  String get editRecentCoffees => 'Edit recent coffees';

  @override
  String get editRecentCoffeesTitle => 'Coffees from the last 24 hours';

  @override
  String get editCoffeeTimeAction => 'Edit coffee time';

  @override
  String get editCoffeeTimeTitle => 'When did you have it?';

  @override
  String get editLastCoffeeTime => 'Change last coffee time';

  @override
  String get editTime => 'Change time';

  @override
  String coffeeTimeUpdatedToday(String time) {
    return 'Coffee moved to $time today.';
  }

  @override
  String coffeeTimeUpdatedYesterday(String time) {
    return 'Coffee moved to $time yesterday.';
  }

  @override
  String get noCoffeeYet => 'No coffee logged yet';

  @override
  String get actionFailed => 'The action could not be completed.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get retry => 'Try again';

  @override
  String get statsTitle => 'Your coffee at a glance';

  @override
  String get statsSubtitle => 'A simple view of your coffee day.';

  @override
  String welcomeName(String name) {
    return 'Hello, $name';
  }

  @override
  String get coffeesToday => 'Coffees today';

  @override
  String get coffeeStatus => 'Coffee status';

  @override
  String get coffeeStatusNoCoffeeToday => 'No coffee today';

  @override
  String get coffeeStatusCalm => 'All good';

  @override
  String get coffeeStatusCoffeeShift => 'Coffee shift';

  @override
  String get coffeeStatusEspressoDrive => 'Espresso drive';

  @override
  String get coffeeStatusCoffeeAfterCoffee => 'Coffee after coffee';

  @override
  String get firstCoffeeToday => 'First today';

  @override
  String get lastCoffeeToday => 'Last today';

  @override
  String get averageIntervalToday => 'Average interval';

  @override
  String get coffeesThisMonth => 'This month';

  @override
  String get totalCoffees => 'All time';

  @override
  String get noData => 'No data yet';

  @override
  String get notAvailable => '—';

  @override
  String minutesValue(String value) {
    return '$value min';
  }

  @override
  String get removeLastCoffee => 'Remove latest coffee';

  @override
  String get removeCoffeeTitle => 'Remove latest coffee?';

  @override
  String get removeCoffeeBody =>
      'The timer and statistics will return to the previous coffee on all your devices.';

  @override
  String get removeCoffeeEntryTitle => 'Remove this entry?';

  @override
  String get removeCoffeeEntryBody =>
      'This coffee will disappear from your overview and CAF level on all devices.';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileSection => 'Profile';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get displayNameHint => 'Optional, up to 80 characters';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get languageSection => 'Language';

  @override
  String get systemLanguage => 'Device language';

  @override
  String get czech => 'Čeština';

  @override
  String get english => 'English';

  @override
  String get accountSection => 'Account';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get logout => 'Sign out';

  @override
  String get rateApp => 'Rate CaffAlert';

  @override
  String get rateAppHint =>
      'Enjoying CaffAlert? Leave a rating on Google Play.';

  @override
  String get couldNotOpenStore => 'We could not open Google Play.';

  @override
  String get androidAppHint =>
      'CaffAlert is on Android too, with a home-screen widget and a reminder when CAF hits zero.';

  @override
  String get getOnGooglePlay => 'Get it on Google Play';

  @override
  String get feedbackSection => 'Support CaffAlert';

  @override
  String get feedbackHint =>
      'Have an idea, found a problem, or want to improve something? Send the developer a note.';

  @override
  String get contactDeveloper => 'Contact the developer';

  @override
  String get couldNotOpenEmail => 'We could not open your email app.';

  @override
  String get aboutCaffAlertSection => 'How CaffAlert works';

  @override
  String get aboutCaffAlertHint =>
      'Keep your caffeine rhythm and CAF level in view throughout the day.';

  @override
  String get caffEmergencyBrief => 'Read about CaffAlert';

  @override
  String get caffEmergencyTitle => 'About CaffAlert';

  @override
  String get caffEmergencyBody =>
      'CaffAlert is a playful coffee diary. Log a coffee, an energy drink, or another caffeinated drink — each log sets your CAF level to 100% and joins your history.\n\nCAF level then drops evenly to zero over four hours. At a glance, you can see when you last logged something and what your coffee day looks like.\n\nFour hours is a game rule, not a recommendation. CAF level only counts the time since your latest log: it does not measure caffeine in your body and does not tell you how much to drink.\n\nCaffAlert is neither a diet nor a limiter. It is a simple overview and — if you switch it on — a single reminder when the countdown ends.';

  @override
  String get appDisclaimerTitle => 'Disclaimer';

  @override
  String get appDisclaimerBody =>
      'CaffAlert is a humorous app and CAF level is a fictional game indicator based on the time since a log. It does not measure caffeine in your body and is not health advice or a guide to how much caffeine to drink.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountHint =>
      'Permanently deletes your account, profile, and all coffee logs.';

  @override
  String get deleteAccountTitle => 'Delete your account and all data?';

  @override
  String get deleteAccountBody =>
      'This cannot be undone. Your profile, coffee logs, and sign-in account will be deleted.';

  @override
  String get deleteAccountConfirm => 'Delete account';

  @override
  String get privacyPolicy => 'Privacy';

  @override
  String get termsOfUse => 'Terms';

  @override
  String get deleteAccountWeb => 'Delete account';

  @override
  String get loadingData => 'Loading your coffee data…';

  @override
  String get errorLoadingData => 'We could not load your data.';

  @override
  String get emptyStatsTitle => 'Your first coffee will appear here';

  @override
  String get emptyStatsBody =>
      'Log a coffee on the main screen to start building your overview.';

  @override
  String get onboardingEyebrow => 'CAF SYSTEM // START';

  @override
  String get onboardingWelcomeTitle => 'Welcome to CaffAlert';

  @override
  String get onboardingWelcomeBody =>
      'Your day moves fast. CaffAlert helps you keep your caffeine rhythm in view.';

  @override
  String get onboardingLogTitle => 'Every log counts';

  @override
  String get onboardingLogBody =>
      'Log a coffee, an energy drink, or another caffeinated drink. Each log sets your CAF level to 100%.';

  @override
  String get onboardingTrackTitle => 'The four-hour protocol';

  @override
  String get onboardingTrackBody =>
      'After every log, a four-hour CAF countdown runs from 100% to zero. It is a game rule, not health advice.';

  @override
  String get onboardingNext => 'Continue';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStart => 'Log your first coffee';

  @override
  String get undo => 'Undo';

  @override
  String get widgetUndo => 'Undo';

  @override
  String get coffeeUndone => 'Coffee removed.';

  @override
  String cafZeroAt(String time) {
    return 'CAF hits zero at $time';
  }

  @override
  String cafZeroTomorrowAt(String time) {
    return 'CAF hits zero tomorrow at $time';
  }

  @override
  String lastCoffeeAt(String time) {
    return 'Last coffee at $time';
  }

  @override
  String lastCoffeeOn(String date) {
    return 'Last coffee $date';
  }

  @override
  String caffCountdownLength(String value) {
    return '$value countdown';
  }

  @override
  String get caffToZero => 'to zero';

  @override
  String get caffZeroTitle => 'CAF at zero';

  @override
  String get caffZeroHint => 'Coffee, water, or a break?';

  @override
  String get caffLowHint => 'Almost at zero';

  @override
  String get caffEmptyHint =>
      'Log a coffee to start the four-hour CAF countdown.';

  @override
  String coffeesTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coffees today',
      one: '$count coffee today',
      zero: 'No coffee yet today',
    );
    return '$_temp0';
  }

  @override
  String get todayTimelineEmpty =>
      'Today\'s first coffee will show up here on the timeline.';

  @override
  String todayTimelineSemantics(String times) {
    return 'Today\'s coffees: $times';
  }

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get cafAlertToggle => 'Notify me when CAF hits zero';

  @override
  String get cafAlertToggleHint =>
      'A single notification when the four-hour countdown ends. It is scheduled on this phone only; nothing is sent anywhere.';

  @override
  String get cafAlertEnabledMessage =>
      'Done. We\'ll ping you when CAF hits zero.';

  @override
  String get cafAlertPermissionDenied =>
      'This needs notification permission. Allow it in Android settings and try again.';

  @override
  String get openSystemSettings => 'Settings';

  @override
  String get cafAlertChannelName => 'CAF at zero';

  @override
  String get cafAlertChannelDescription =>
      'A single reminder when the four-hour CAF countdown ends.';

  @override
  String get cafAlertNotificationTitle => 'CAF at zero ☕';

  @override
  String get cafAlertNotificationBody =>
      'Countdown\'s done. Coffee, a glass of water, or five minutes of fresh air? Your call.';

  @override
  String get legalSection => 'Legal';

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get termsOfUseLink => 'Terms of Use';

  @override
  String get couldNotOpenLink => 'We could not open the link.';
}
