# CaffAlert: vydání na Google Play (checklist)

Osobní vývojářský účet, balíček `com.frantisekbujnovsky.caffalert`, verze **1.1.0+2** (`pubspec.yaml` → `versionName 1.1.0`, `versionCode 2`). Podklady: [`listing.md`](listing.md) (texty), [`data-safety.md`](data-safety.md) (formuláře a soulad se zásadami), [`graphics/`](graphics/) (ikona, grafika funkce).

Pravidla repa platí i tady: nic do Play Console, na Netlify ani na GitHub bez Františkova „pushni“. Tajemství (`.env`, `android/key.properties`, keystore) nikdy do gitu.

## Ověřená pravidla Google Play (stav 14. 11. 2026)

| Pravidlo | Co to znamená pro CaffAlert | Zdroj (ověřeno 14. 11. 2026) |
| --- | --- | --- |
| Osobní účty založené **po 13. 11. 2023** musí před produkcí projít **uzavřeným testováním s alespoň 12 testery, kteří jsou přihlášení nepřetržitě alespoň 14 dní**. Teprve pak jde požádat o přístup do produkce. | Počítej minimálně se 14 dny + dny na schválení žádosti. Testerů raději 15–20, kdyby někdo vypadl. | [Play Console Help: App testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465) |
| Od **31. 8. 2026** musí nové aplikace a aktualizace cílit na **Android 16 (API 36)** nebo vyšší (výjimky jen Wear OS, Automotive, TV, XR). Prodloužení šlo žádat nejdéle do 1. 11. 2026. | Flutter 3.47.9 má `flutter.targetSdkVersion = 36` a `compileSdkVersion = 36` (`~/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt`, řádky 23 a 34); `android/app/build.gradle.kts` ho přebírá (`targetSdk = flutter.targetSdkVersion`). **Splněno.** `minSdk` je 24 (Android 7.0). | [Android Developers: Meet Google Play's target API level requirement](https://developer.android.com/google/play/requirements/target-sdk) |
| Osobní účet: jednorázový poplatek **25 USD**, ověření identity (doklad + karta na stejné jméno), **ověření přístupu k Android zařízení** přes mobilní aplikaci Play Console, věk 18+. | Viz ruční kroky níže. | [Play Console Help: Get started with Play Console](https://support.google.com/googleplay/android-developer/answer/6112435) |
| Aplikace s účty musí mít smazání účtu **v aplikaci** i na **webu** a webový odkaz uvést v Data safety. | Splněno: Nastavení → Smazat účet; https://caff-alert.netlify.app/delete-account. | [Play Console Help: Understanding Google Play's app account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111) |
| Zásady ochrany soukromí musí být v poli Play Console **i v aplikaci**. | Splněno: Nastavení → Právní informace → Zásady ochrany soukromí / Podmínky použití (`lib/settings_screen.dart`). | [Play Console Help: User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311) |
| Deklaraci zdravotních aplikací vyplňuje každá aplikace, i bez zdravotních funkcí. | Odpověď „žádné zdravotní funkce“. | [Play Console Help: Health apps declaration](https://support.google.com/googleplay/android-developer/answer/14738291) |
| Grafika: ikona 512 × 512 32bit PNG s alfou (max 1 MB), grafika funkce 1024 × 500 JPEG/24bit PNG bez alfy, snímky viz níže. | Hotovo v `graphics/`. | [Play Console Help: Add preview assets](https://support.google.com/googleplay/android-developer/answer/9866151) |
| Android developer verification: od 30. 9. 2026 v Brazílii, Indonésii, Singapuru a Thajsku, globálně v roce 2027. Aplikace z Google Play se registrují automaticky přes Play Console. | Při distribuci přes Play nic navíc. APK z GitHub Releases bude pro tyto země (a od 2027 všude) potřebovat registraci balíčku v Play Console. | [Android Developers: Android developer verification](https://developer.android.com/developer-verification/guides) |

## 1. Před buildem

- [ ] Ostatní práce (widget, obrazovky, upozornění) jsou dokončené, `flutter analyze` a `flutter test` projdou.
- [x] Odkaz na zásady ochrany soukromí i podmínky je v Android aplikaci (Nastavení → Právní informace).
- [ ] `/privacy` a `/terms` (EN i CS) jsou doplněné (platné od 14. 11. 2026, viz `data-safety.md` → Soulad) a čekají na nasazení na Netlify (po „pushni“).
- [ ] `pubspec.yaml`: `version: 1.1.0+2` (hotovo). Při každém dalším nahrání **musí stoupnout číslo za `+`** (versionCode).
- [x] Sentry `release` se skládá z verze aplikace (`package_info_plus` v `lib/main.dart`), ručně se nemění.
- [ ] `.env` pro release obsahuje produkční `SUPABASE_URL` a `SUPABASE_PUBLISHABLE_KEY` (nikdy service-role klíč). `SENTRY_DSN` podle zvolené varianty v `data-safety.md` (A = prázdný).
- [ ] Supabase → Authentication → URL Configuration: v Redirect URLs je `com.frantisekbujnovsky.caffalert://login-callback` (potvrzovací e-mail a reset hesla se vrací do aplikace) a produkční web. Vlastní SMTP nastavené (výchozí mailer Supabase má nízké limity, recenze a testeři budou registrovat účty).
- [ ] Podpisový klíč: `android/key.properties` existuje a je v gitu ignorovaný (`android/.gitignore`: `key.properties`; kořenový `.gitignore`: `android/key.properties`, `*.jks`, `*.keystore`; ověřeno `git check-ignore`, obsah se nečetl). Keystore a hesla mají zálohu mimo tento počítač (správce hesel). **Ztráta upload klíče = žádost o reset v Play Console, ztráta app signing klíče u vlastního klíče = konec aktualizací.**

## 2. Build

```sh
flutter clean            # jen když se měnily nativní části / ikony
flutter pub get
flutter build appbundle --release --dart-define-from-file=.env
```

Výstup: **`build/app/outputs/bundle/release/app-release.aab`**. Bez `android/key.properties` se release nepodepíše (záměrně, žádný fallback na debug klíč) a Play takový balík odmítne.

Kontrola před nahráním:

```sh
# verze, target SDK a oprávnění ve výsledném balíku (bundletool: brew install bundletool)
bundletool dump manifest --bundle build/app/outputs/bundle/release/app-release.aab | grep -E 'uses-permission|targetSdk|versionCode|versionName'
```

Očekávané: `versionCode 2`, `versionName 1.1.0`, `targetSdkVersion 36`; oprávnění jen `INTERNET`, `POST_NOTIFICATIONS`, `VIBRATE`, `RECEIVE_BOOT_COMPLETED`, `WAKE_LOCK`, `ACCESS_NETWORK_STATE`, `FOREGROUND_SERVICE` a interní `…DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (`RECEIVE_BOOT_COMPLETED` deklaruje přímo `AndroidManifest.xml` kvůli obnovení upozornění po restartu, navíc ho přináší `androidx.work`). **Žádné** `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` / `AD_ID`. Když přibude jiné oprávnění, uprav `data-safety.md` a Console.

Nainstaluj release build na skutečný telefon (Android 13+) a projdi: registrace a potvrzení e-mailu → zápis kávy → widget (přidání ve výchozí velikosti 4 × 2, čas „CAF na nule v …“, „+ Káva“ otevře aplikaci a zapíše jednu kávu, i po otevření z Nedávných jen jednu; zmenšení na 2 × 2 bez tlačítka) → upozornění (zapnutí, odmítnutí oprávnění) → změna jazyka → smazání účtu.

## 3. Play App Signing a upload klíč

Nové aplikace musí používat Android App Bundle a **Play App Signing**: Google drží klíč, kterým podepisuje APK pro uživatele, ty nahráváš AAB podepsaný **upload klíčem** (to je keystore z `android/key.properties`).

Rozhodnutí při prvním nahrání (*Nastavení → Integrita aplikace → Podepisování aplikací*):

- **Klíč vygenerovaný Googlem (výchozí, doporučeno).** Nejbezpečnější. Ale APK z GitHub Releases (podepsané tvým klíčem) a verze z Play budou mít **jiný podpis**: kdo má APK z GitHubu, musí aplikaci před instalací z Play odinstalovat (přijde o nic, data jsou v účtu).
- **Vlastní klíč jako app signing key** (export nástrojem PEPK podle návodu v Console). Pak mají GitHub APK i Play stejný podpis, ale za ztrátu klíče odpovídáš sám. Upload klíč pak musí být jiný než podpisový.

Po nahrání si z Console poznamenej SHA-256 otisky obou klíčů (Supabase je nepotřebuje; hodí se pro případné App Links).

## 4. Play Console: postup prvního vydání

1. **Vytvořit aplikaci:** název `CaffAlert: kávový deníček`, výchozí jazyk čeština, typ Aplikace, zdarma, souhlas s pravidly.
2. **Obsah aplikace** (vše z [`data-safety.md`](data-safety.md)): zásady ochrany soukromí `https://caff-alert.netlify.app/privacy`, přístup do aplikace (testovací účet), reklamy (ne), hodnocení obsahu (IARC), cílová skupina (18+), Data safety (odkaz na smazání `https://caff-alert.netlify.app/delete-account`), reklamní ID (ne), zdravotní aplikace (žádné zdravotní funkce), vládní / finanční / zpravodajské (ne).
3. **Prezentace v obchodě:** texty z [`listing.md`](listing.md) (cs-CZ a přidat překlad en-US), ikona `graphics/icon-512.png`, grafika funkce `graphics/feature-graphic.png` (cs) a `graphics/feature-graphic-en.png` (en), snímky telefonu, kategorie Životní styl, kontaktní e-mail.
4. **Testování → Uzavřené testování:** vytvořit stopu (nebo použít „Alpha“), seznam testerů (Google účty, e-mailová skupina nebo Google Group), země (Česko + kde jsou testeři), nahrát `app-release.aab`, poznámky k verzi (viz níže), odeslat ke kontrole.
5. Po schválení rozeslat testerům **odkaz pro přihlášení** (opt-in URL). Tester musí odkaz otevřít, přijmout pozvánku a aplikaci nainstalovat z Play. Počítá se **nepřetržité přihlášení 14 dní**; kdo se odhlásí, vypadává.
6. Během 14 dní sbírat zpětnou vazbu, opravit chyby, případně nahrát nový build (versionCode +1) do stejné uzavřené stopy. Testery v ní nech, aby jejich přihlášení běželo dál.
7. **Dashboard → Požádat o přístup do produkce:** dotazník o průběhu testu (jak jsi testery získal, jakou zpětnou vazbu dali, co se změnilo, proč je aplikace připravená). Odpovídej konkrétně. Posouzení žádosti může trvat několik dní.
8. **Produkce:** vytvořit vydání z ověřeného AAB, země, **postupné zavádění** (např. 20 % → 100 %), odeslat ke kontrole. Recenze nové aplikace může trvat i několik dní.

Poznámky k verzi 1.1.0 (cs / en):

```text
<cs-CZ>
První verze na Google Play: zápis kávy jedním klepnutím, hravý CAF odpočet, widget s časem, kdy bude CAF na nule, a tlačítkem „+ Káva“, volitelné upozornění na nulu, statistiky a synchronizace s webem.
</cs-CZ>
<en-US>
First Google Play release: one-tap coffee logging, a playful CAF countdown, a widget showing when CAF hits zero with a "+ Coffee" button, an optional CAF-at-zero reminder, stats and sync with the web app.
</en-US>
```

## 5. Snímky obrazovky (z emulátoru nebo telefonu)

Požadavky Play: **min. 2, max. 8** snímků na typ zařízení; PNG (24bit, **bez alfy**) nebo JPEG; kratší strana ≥ 320 px, delší ≤ 3840 px; **delší strana nejvýš 2× kratší**. Pro doporučování ve výsledcích Google chce aspoň 4 snímky, na výšku **9:16, min. 1080 × 1920**.

- Doporučený formát: **1080 × 1920** (9:16) PNG bez průhlednosti, 4–6 snímků.
- **Pozor:** Pixel 7 / většina moderních emulátorů snímá 1080 × 2400 (poměr 2,22:1), to Play **odmítne**. Buď emulátor s 1080 × 1920 (420 dpi), nebo snímek ořezat na 1080 × 2160 (2:1) či 1080 × 1920 (stavový řádek a navigační lišta pryč).
- Odstranit alfa kanál: `python3 -c "from PIL import Image; im=Image.open('a.png').convert('RGB'); im.save('a.png')"`.
- Obsah: hlavní obrazovka s „CAF na nule v …“, widget na ploše (4 × 2 s „+ Káva“), statistiky, nastavení s upozorněním, případně web. Účet s ukázkovými daty (žádné skutečné e-maily na snímcích), čas v hodinách stavového řádku rozumný (např. 9:41), čeština pro cs-CZ, angličtina pro en-US.
- Tablety (7" a 10") nejsou povinné; aplikace je jen na telefony, sekci nechat prázdnou.

Uložit do `docs/play-store/screenshots/{cs,en}/01-…png`.

## 6. Každé další vydání

1. Zvýšit `version` v `pubspec.yaml` (`1.1.1+3`, …), **versionCode vždy +1** oproti poslednímu nahranému buildu, i do testovací stopy.
2. Sentry `release` se převezme z verze automaticky (`package_info_plus`), nic ručně.
3. `flutter analyze`, `flutter test`, při změně DB `npm run db:test` a `npm run db:lint`; nové migrace nasadit na Supabase dřív, než vyjde aplikace, která je potřebuje.
4. Nové oprávnění, SDK, analytika, reklamy nebo platby → upravit `/privacy`, `/terms`, `data-safety.md` a Data safety v Console **před** vydáním.
5. `flutter build appbundle --release --dart-define-from-file=.env`, ověřit manifest (krok 2), otestovat release na telefonu.
6. Nahrát do uzavřené / interní stopy, otestovat, pak „Povýšit vydání“ do produkce s postupným zaváděním.
7. Poznámky k verzi CZ + EN; při změně funkcí aktualizovat `listing.md`, snímky a grafiku.
8. Hlídat e-maily z Play Console (změny zásad; požadavek na target API se zvedá zhruba jednou ročně, naposledy 31. 8. 2026) a každoročně zkontrolovat Flutter (`flutter.targetSdkVersion`).
9. Tag `v1.1.x` spustí workflow s podepsaným APK pro GitHub Releases. Pozor na rozdílný podpis oproti Play (krok 3).

## 7. Ruční kroky pro Františka

1. **Účet Play Console** (https://play.google.com/console/signup): osobní účet, Google účet, který chceš mít k aplikaci napořád (ideálně ne pracovní).
2. **Poplatek 25 USD** jednorázově, kreditní nebo debetní karta (ne předplacená) na tvé jméno.
3. **Ověření identity:** občanský průkaz nebo pas + karta na stejné jméno; počkat na schválení (hodiny až dny).
4. **Ověření Android zařízení:** nainstalovat aplikaci *Google Play Console* na svůj Android telefon a v ní potvrdit přístup.
5. **Ověřit kontaktní e-mail a telefon** v profilu účtu; zvolit veřejný **kontaktní e-mail** pro obchod (doplnit do `listing.md` místo `{{KONTAKTNI_EMAIL}}`).
6. **Status obchodníka (EU DSA):** Console se zeptá, jestli jsi „obchodník“ (trader). Máš IČO; pokud aplikaci bereš jako součást podnikání, jsi obchodník a Play **zveřejní adresu, telefon a e-mail**. Bezplatný osobní projekt bez příjmů může být „neobchodník“. Rozhodni sám (případně s účetní nebo právníkem).
7. **Testovací účet pro recenzi:** založit v aplikaci účet na samostatný e-mail, potvrdit ho, zapsat pár káv a údaje vložit do *Přístup do aplikace*. Nemazat ho.
8. **12+ testerů** (raději 15–20) s Google účtem na Androidu: přidat jejich e-maily do uzavřeného testu, poslat jim odkaz pro přihlášení a ohlídat, aby se 14 dní neodhlásili a aplikaci aspoň párkrát použili.
9. **Rozhodnout Sentry** (varianta A / B v `data-safety.md`) a **podpisový klíč** (Google vs. vlastní, krok 3).
10. Schválit úpravy zásad a podmínek (platné od 14. 11. 2026), pak dát „pushni“ pro Netlify a Play Console.
11. Po 14 dnech **požádat o přístup do produkce** a vyplnit dotazník; po schválení vydat produkci.
