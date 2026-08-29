// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'CaffAlert';

  @override
  String get configurationErrorTitle => 'CaffAlert potřebuje nastavit';

  @override
  String get configurationErrorBody =>
      'Doplň SUPABASE_URL a SUPABASE_PUBLISHABLE_KEY a aplikaci znovu sestav.';

  @override
  String get authWelcomeTitle => 'Nenech hladinu kofeinu spadnout na nulu.';

  @override
  String get authWelcomeSubtitle =>
      'Sleduj svůj kofeinový rytmus. Jakmile CAF level klesne, je čas ho doplnit.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Heslo';

  @override
  String get confirmPasswordLabel => 'Potvrzení hesla';

  @override
  String get signIn => 'Přihlásit se';

  @override
  String get signUp => 'Vytvořit účet';

  @override
  String get switchToSignUp => 'Jsi tu poprvé? Vytvoř si účet';

  @override
  String get switchToSignIn => 'Už máš účet? Přihlas se';

  @override
  String get forgotPassword => 'Zapomenuté heslo?';

  @override
  String get resetPasswordTitle => 'Obnovení hesla';

  @override
  String get resetPasswordBody =>
      'Zadej e-mail a pošleme ti bezpečný odkaz pro nastavení nového hesla.';

  @override
  String get sendResetLink => 'Poslat odkaz';

  @override
  String get backToSignIn => 'Zpět na přihlášení';

  @override
  String get emailRequired => 'Zadej svůj e-mail.';

  @override
  String get emailInvalid => 'Zadej platnou e-mailovou adresu.';

  @override
  String get passwordRequired => 'Zadej své heslo.';

  @override
  String get passwordTooShort => 'Použij alespoň 8 znaků.';

  @override
  String get passwordsDoNotMatch => 'Hesla se neshodují.';

  @override
  String get authGenericError => 'Něco se nepovedlo. Zkus to prosím znovu.';

  @override
  String get invalidCredentials => 'E-mail nebo heslo není správné.';

  @override
  String get emailNotConfirmed => 'Před přihlášením potvrď svůj e-mail.';

  @override
  String get accountExists => 'Účet s tímto e-mailem už existuje.';

  @override
  String get rateLimited =>
      'Příliš mnoho pokusů. Chvíli počkej a zkus to znovu.';

  @override
  String get confirmationSentTitle => 'Zkontroluj e-mail';

  @override
  String get confirmationSentBody =>
      'Poslali jsme ti potvrzovací odkaz. Otevři ho a pak se vrať k přihlášení.';

  @override
  String get resetLinkSent => 'Odkaz pro obnovení hesla je na cestě.';

  @override
  String get updatePasswordTitle => 'Zvol si nové heslo';

  @override
  String get updatePasswordBody =>
      'Odkaz jsme ověřili. Pro pokračování si nastav nové heslo.';

  @override
  String get newPasswordLabel => 'Nové heslo';

  @override
  String get savePassword => 'Uložit heslo';

  @override
  String get passwordUpdated => 'Heslo bylo změněno.';

  @override
  String get timerNavigation => 'Časovač';

  @override
  String get statsNavigation => 'Statistiky';

  @override
  String get settingsNavigation => 'Nastavení';

  @override
  String get timerEyebrow => 'TVŮJ KÁVOVÝ RYTMUS';

  @override
  String get nextCoffeeIn => 'CAF úroveň na nule za';

  @override
  String get coffeeReady => 'CAF úroveň je na nule';

  @override
  String get coffeeReadySubtitle => 'Jdi si dát kávu.';

  @override
  String get coffeeLowLevelWarning => 'Pozor, CAF úroveň se blíží nule.';

  @override
  String get caffLevel => 'CAF úroveň';

  @override
  String caffLevelValue(int value) {
    return 'CAF úroveň: $value %';
  }

  @override
  String get logCoffee => 'Měl/a jsem kávu';

  @override
  String get coffeeLogged => 'CAF level doplněn.';

  @override
  String get lastCoffee => 'Poslední káva';

  @override
  String get editRecentCoffees => 'Upravit nedávné kávy';

  @override
  String get editRecentCoffeesTitle => 'Kávy z posledních 24 hodin';

  @override
  String get editCoffeeTimeAction => 'Upravit čas kávy';

  @override
  String get editCoffeeTimeTitle => 'Kdy byla káva?';

  @override
  String get editCoffeeTimeOutOfRange =>
      'Čas kávy musí být v posledních 24 hodinách.';

  @override
  String get coffeeTimeUpdated => 'Čas kávy je upravený.';

  @override
  String get noCoffeeYet => 'Zatím žádná káva';

  @override
  String get actionFailed => 'Akci se nepodařilo dokončit.';

  @override
  String get dismiss => 'Skrýt';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get statsTitle => 'Tvůj kofein v kostce';

  @override
  String get statsSubtitle => 'Jednoduchý přehled tvého kofeinového rytmu.';

  @override
  String welcomeName(String name) {
    return 'Ahoj, $name';
  }

  @override
  String get coffeesToday => 'Káv dnes';

  @override
  String get coffeeStatus => 'Kávový status';

  @override
  String get coffeeStatusNoCoffeeToday => 'Dnešek bez kávy';

  @override
  String get coffeeStatusCalm => 'V pohodě';

  @override
  String get coffeeStatusCoffeeShift => 'Kávová směna';

  @override
  String get coffeeStatusEspressoDrive => 'Espresso pohon';

  @override
  String get coffeeStatusLegend => 'Kávová legenda';

  @override
  String get firstCoffeeToday => 'První dnes';

  @override
  String get lastCoffeeToday => 'Poslední dnes';

  @override
  String get averageIntervalToday => 'Průměrný rozestup';

  @override
  String get coffeesThisMonth => 'Tento měsíc';

  @override
  String get totalCoffees => 'Celkem';

  @override
  String get noData => 'Zatím bez dat';

  @override
  String get notAvailable => '—';

  @override
  String minutesValue(String value) {
    return '$value min';
  }

  @override
  String get removeLastCoffee => 'Odstranit poslední kávu';

  @override
  String get removeCoffeeTitle => 'Odstranit poslední kávu?';

  @override
  String get removeCoffeeBody =>
      'Časovač i statistiky se na všech zařízeních vrátí k předchozí kávě.';

  @override
  String get removeCoffeeEntryTitle => 'Odstranit tento záznam?';

  @override
  String get removeCoffeeEntryBody =>
      'Káva zmizí z přehledu i CAF levelu na všech zařízeních.';

  @override
  String get cancel => 'Zrušit';

  @override
  String get remove => 'Odstranit';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get profileSection => 'Profil';

  @override
  String get displayNameLabel => 'Zobrazované jméno';

  @override
  String get displayNameHint => 'Volitelné, maximálně 80 znaků';

  @override
  String get save => 'Uložit';

  @override
  String get saved => 'Uloženo';

  @override
  String get languageSection => 'Jazyk';

  @override
  String get systemLanguage => 'Jazyk zařízení';

  @override
  String get czech => 'Čeština';

  @override
  String get english => 'English';

  @override
  String get accountSection => 'Účet';

  @override
  String get signedInAs => 'Přihlášený účet';

  @override
  String get logout => 'Odhlásit se';

  @override
  String get rateApp => 'Ohodnotit CaffAlert';

  @override
  String get rateAppHint =>
      'Líbí se ti CaffAlert? Dej mu hodnocení na Google Play.';

  @override
  String get couldNotOpenStore => 'Nepodařilo se otevřít Google Play.';

  @override
  String get caffLevelInfoTitle => 'O CAF levelu';

  @override
  String get caffLevelInfoBody =>
      'CAF level je fiktivní herní ukazatel založený jen na čase od posledního záznamu. Neměří kofein v těle ani nepředstavuje zdravotní doporučení.';

  @override
  String get deleteAccount => 'Smazat účet';

  @override
  String get deleteAccountHint =>
      'Trvale odstraní účet, profil a všechny záznamy kávy.';

  @override
  String get deleteAccountTitle => 'Smazat účet a všechna data?';

  @override
  String get deleteAccountBody =>
      'Tato akce je nevratná. Odstraní se profil, záznamy kávy i přihlašovací účet.';

  @override
  String get deleteAccountConfirm => 'Smazat účet';

  @override
  String get loadingData => 'Načítám tvoje kávová data…';

  @override
  String get errorLoadingData => 'Tvoje data se nepodařilo načíst.';

  @override
  String get emptyStatsTitle => 'První dávka kofeinu se objeví tady';

  @override
  String get emptyStatsBody =>
      'Zaznamenej dávku na obrazovce časovače a začne se tvořit přehled.';
}
