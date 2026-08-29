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
  String get authWelcomeTitle => 'Don\'t let your caffeine level hit zero.';

  @override
  String get authWelcomeSubtitle =>
      'Follow your caffeine rhythm. When your CAF level drops, it is time to top it up.';

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
  String get nextCoffeeIn => 'CAF level reaches zero in';

  @override
  String get coffeeReady => 'CAF level is at zero';

  @override
  String get coffeeReadySubtitle => 'Time to brew a coffee.';

  @override
  String get coffeeLowLevelWarning =>
      'Heads up, your CAF level is nearing zero.';

  @override
  String get caffLevel => 'CAF level';

  @override
  String caffLevelValue(int value) {
    return 'CAF level: $value%';
  }

  @override
  String get logCoffee => 'I had a coffee';

  @override
  String get coffeeLogged => 'CAF level replenished.';

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
  String get editCoffeeTimeOutOfRange =>
      'Coffee time must be within the last 24 hours.';

  @override
  String get coffeeTimeUpdated => 'Coffee time updated.';

  @override
  String get noCoffeeYet => 'No coffee logged yet';

  @override
  String get actionFailed => 'The action could not be completed.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get retry => 'Try again';

  @override
  String get statsTitle => 'Your caffeine at a glance';

  @override
  String get statsSubtitle => 'A simple view of your caffeine rhythm.';

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
  String get coffeeStatusLegend => 'Coffee legend';

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
      'CaffAlert is a tool for keeping your caffeine rhythm in view throughout the day. Log a coffee, an energy drink, or another caffeinated drink — every log replenishes your CAF level and joins your history.\n\nCAF level then gradually drops over four hours. At a glance, you can see when you last logged something, how often you return to caffeine, and when the system starts dramatically asking for attention.\n\nWhy four hours? Current literature puts the average plasma half-life of caffeine in healthy adults at roughly five hours, although it varies considerably between people. CaffAlert took the practical four-hour part and declared its own standard CAF Protocol. When the fictional CAF level reaches its critical zone, the system dramatically suggests considering a refill. It sounds scientific; it is still a game indicator, not a measurement of your body.\n\nCaffAlert is neither a diet nor a limiter. It is a simple overview that keeps your caffeine rhythm visible. Stay caffeinated.';

  @override
  String get appDisclaimerTitle => 'Disclaimer';

  @override
  String get appDisclaimerBody =>
      'CAF level is a fictional game indicator based on the time since a log. It does not measure caffeine in your body and is not health advice or a guide to how much caffeine to drink.';

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
  String get emptyStatsTitle => 'Your first caffeine dose will appear here';

  @override
  String get emptyStatsBody =>
      'Log a dose on the timer screen to start building your overview.';

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
      'Log a coffee, an energy drink, or another caffeinated drink. Each log replenishes your CAF level.';

  @override
  String get onboardingTrackTitle => 'The four-hour protocol';

  @override
  String get onboardingTrackBody =>
      'Current literature places the caffeine half-life in healthy adults at roughly five hours. CaffAlert uses a practical four-hour standard CAF Protocol; after that, the fictional CAF level enters its critical zone and the system suggests considering a refill.';

  @override
  String get onboardingSource => 'CaffAlert Protocol source';

  @override
  String get onboardingSourceTitle => 'CaffAlert Protocol source';

  @override
  String get onboardingSourceMeme => 'I made it up.';

  @override
  String get onboardingNext => 'Continue';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStart => 'Log your first coffee';
}
