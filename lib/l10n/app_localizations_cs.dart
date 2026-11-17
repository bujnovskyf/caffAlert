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
  String get authWelcomeTitle => 'Tvůj kávový den, hravě a přehledně.';

  @override
  String get authWelcomeSubtitle =>
      'Zapiš kávu a sleduj hravý CAF odpočet. Je to herní ukazatel, ne měření kofeinu.';

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
  String get coffeeReady => 'CAF úroveň je na nule';

  @override
  String get coffeeReadySubtitle => 'Káva, voda, nebo pauza? Je to na tobě.';

  @override
  String get caffLevel => 'CAF úroveň';

  @override
  String caffLevelValue(int value) {
    return 'CAF úroveň: $value %';
  }

  @override
  String get logCoffee => 'Zapsat kávu';

  @override
  String get coffeeLogged => 'Káva zapsána. CAF je na 100 %.';

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
  String get editLastCoffeeTime => 'Upravit čas poslední kávy';

  @override
  String get editTime => 'Upravit čas';

  @override
  String coffeeTimeUpdatedToday(String time) {
    return 'Káva přesunutá na dnešek $time.';
  }

  @override
  String coffeeTimeUpdatedYesterday(String time) {
    return 'Káva přesunutá na včera $time.';
  }

  @override
  String get noCoffeeYet => 'Zatím žádná káva';

  @override
  String get actionFailed => 'Akci se nepodařilo dokončit.';

  @override
  String get dismiss => 'Skrýt';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get statsTitle => 'Tvoje káva v kostce';

  @override
  String get statsSubtitle => 'Jednoduchý přehled tvého kávového dne.';

  @override
  String welcomeName(String name) {
    return 'Ahoj, $name';
  }

  @override
  String get coffeesToday => 'Kávy dnes';

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
  String get coffeeStatusCoffeeAfterCoffee => 'Káva za kávou';

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
  String get androidAppHint =>
      'CaffAlert je i na Androidu: s widgetem na plochu a upozorněním, když CAF klesne na nulu.';

  @override
  String get getOnGooglePlay => 'Stáhnout na Google Play';

  @override
  String get feedbackSection => 'Podpora CaffAlertu';

  @override
  String get feedbackHint =>
      'Máš nápad, našel/a jsi problém nebo chceš něco vylepšit? Napiš vývojáři.';

  @override
  String get contactDeveloper => 'Napsat vývojáři';

  @override
  String get couldNotOpenEmail => 'Nepodařilo se otevřít e-mailovou aplikaci.';

  @override
  String get aboutCaffAlertSection => 'Jak funguje CaffAlert';

  @override
  String get aboutCaffAlertHint =>
      'Měj svůj kofeinový rytmus i CAF level během dne na očích.';

  @override
  String get caffEmergencyBrief => 'Přečíst si o CaffAlertu';

  @override
  String get caffEmergencyTitle => 'O CaffAlertu';

  @override
  String get caffEmergencyBody =>
      'CaffAlert je hravý kávový deníček. Zapiš kávu, energy drink nebo jiný nápoj s kofeinem — záznam nastaví CAF úroveň na 100 % a uloží se do tvé historie.\n\nCAF úroveň pak za čtyři hodiny rovnoměrně klesne na nulu. Na první pohled tak vidíš, kdy sis naposledy něco zapsal/a a jak vypadá tvůj kávový den.\n\nČtyři hodiny jsou herní pravidlo, ne doporučení. CAF úroveň počítá jen čas od posledního záznamu: neměří kofein v těle a neradí, kolik pít.\n\nCaffAlert není dieta ani omezovač. Je to jednoduchý přehled a — pokud si ho zapneš — jedno upozornění, až odpočet doběhne.';

  @override
  String get appDisclaimerTitle => 'Disclaimer';

  @override
  String get appDisclaimerBody =>
      'CaffAlert je vtipná aplikace a CAF úroveň je fiktivní herní ukazatel založený na čase od záznamu. Neměří kofein v těle a nepředstavuje zdravotní doporučení ani návod, kolik kofeinu pít.';

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
  String get privacyPolicy => 'Soukromí';

  @override
  String get termsOfUse => 'Podmínky';

  @override
  String get deleteAccountWeb => 'Smazání účtu';

  @override
  String get loadingData => 'Načítám tvoje kávová data…';

  @override
  String get errorLoadingData => 'Tvoje data se nepodařilo načíst.';

  @override
  String get emptyStatsTitle => 'Tvoje první káva se objeví tady';

  @override
  String get emptyStatsBody =>
      'Zapiš kávu na hlavní obrazovce a začne se tvořit přehled.';

  @override
  String get onboardingEyebrow => 'CAF SYSTEM // START';

  @override
  String get onboardingWelcomeTitle => 'Vítej v CaffAlertu';

  @override
  String get onboardingWelcomeBody =>
      'Tvůj den jede naplno. CaffAlert ti pomůže udržet přehled o tvém kofeinovém rytmu.';

  @override
  String get onboardingLogTitle => 'Každý záznam se počítá';

  @override
  String get onboardingLogBody =>
      'Zaznamenej kávu, energy drink nebo jiný kofeinový nápoj. Každý záznam nastaví CAF level na 100 %.';

  @override
  String get onboardingTrackTitle => 'Čtyřhodinový protokol';

  @override
  String get onboardingTrackBody =>
      'Po každém zápisu běží čtyřhodinový CAF odpočet ze 100 % na nulu. Je to herní pravidlo, ne zdravotní rada.';

  @override
  String get onboardingNext => 'Pokračovat';

  @override
  String get onboardingSkip => 'Přeskočit';

  @override
  String get onboardingStart => 'Zaznamenat první kávu';

  @override
  String get undo => 'Vrátit';

  @override
  String get widgetUndo => 'Vrátit';

  @override
  String get coffeeUndone => 'Káva vrácena.';

  @override
  String cafZeroAt(String time) {
    return 'CAF na nule v $time';
  }

  @override
  String cafZeroTomorrowAt(String time) {
    return 'CAF na nule zítra v $time';
  }

  @override
  String lastCoffeeAt(String time) {
    return 'Poslední káva v $time';
  }

  @override
  String lastCoffeeOn(String date) {
    return 'Poslední káva $date';
  }

  @override
  String caffCountdownLength(String value) {
    return 'Odpočet $value';
  }

  @override
  String get caffToZero => 'do nuly';

  @override
  String get caffZeroTitle => 'CAF na nule';

  @override
  String get caffZeroHint => 'Káva, voda, nebo pauza?';

  @override
  String get caffLowHint => 'Skoro na nule';

  @override
  String get caffEmptyHint =>
      'Zapiš kávu a spustí se čtyřhodinový CAF odpočet.';

  @override
  String coffeesTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dnes $count káv',
      few: 'Dnes $count kávy',
      one: 'Dnes $count káva',
      zero: 'Dnes zatím bez kávy',
    );
    return '$_temp0';
  }

  @override
  String get todayTimelineEmpty =>
      'První dnešní káva se objeví tady na časové ose.';

  @override
  String todayTimelineSemantics(String times) {
    return 'Dnešní kávy: $times';
  }

  @override
  String get notificationsSection => 'Upozornění';

  @override
  String get cafAlertToggle => 'Upozornit, až CAF klesne na nulu';

  @override
  String get cafAlertToggleHint =>
      'Jedna notifikace, když doběhne čtyřhodinový odpočet. Plánuje se jen v tomhle telefonu, nic se neodesílá.';

  @override
  String get cafAlertEnabledMessage =>
      'Hotovo. Ozveme se, až bude CAF na nule.';

  @override
  String get cafAlertPermissionDenied =>
      'Bez povolení notifikací to nepůjde. Povol je v nastavení Androidu a zkus to znovu.';

  @override
  String get openSystemSettings => 'Nastavení';

  @override
  String get cafAlertChannelName => 'CAF na nule';

  @override
  String get cafAlertChannelDescription =>
      'Jedno upozornění, když doběhne čtyřhodinový CAF odpočet.';

  @override
  String get cafAlertNotificationTitle => 'CAF na nule ☕';

  @override
  String get cafAlertNotificationBody =>
      'Odpočet doběhl. Káva, sklenice vody, nebo pět minut na vzduchu? Vyber si.';

  @override
  String get legalSection => 'Právní informace';

  @override
  String get privacyPolicyLink => 'Zásady ochrany soukromí';

  @override
  String get termsOfUseLink => 'Podmínky použití';

  @override
  String get couldNotOpenLink => 'Nepodařilo se otevřít odkaz.';
}
