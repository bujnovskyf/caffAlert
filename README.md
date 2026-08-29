# CaffAlert

CaffAlert je responzivní Flutter deníček kofeinového rytmu s CAF levelem a statistikami. Web je primární platforma, data a přihlášení zajišťuje Supabase. Rozhraní podporuje češtinu i angličtinu.

## Co potřebuješ

- Flutter `3.38.5` (stejná verze je připnutá pro Netlify)
- Node.js 20+
- Docker Desktop, OrbStack nebo jiný Docker-kompatibilní runtime pro lokální Supabase

## Lokální spuštění

1. Nainstaluj projektově připnutý Supabase CLI:

   ```sh
   npm ci
   ```

2. Spusť lokální Supabase a obnov databázi z migrací:

   ```sh
   npm run db:start
   npm run db:reset
   npm run db:test
   ```

3. Připrav lokální konfiguraci:

   ```sh
   cp .env.example .env
   npx supabase status
   ```

   Do `.env` zkopíruj lokální API URL a klientský `anon` klíč. Hodnotu lokálního anon klíče vlož pod název `SUPABASE_PUBLISHABLE_KEY`; parametr SDK podporuje jak nový publishable klíč, tak lokální legacy anon klíč.

4. Spusť aplikaci:

   ```sh
   flutter run -d chrome --web-port 8765 --dart-define-from-file=.env
   ```

Lokální potvrzovací e-maily a obnovu hesla najdeš v Mailpit na `http://localhost:54324`.

## Obnovení nové vzdálené databáze

Původní Supabase endpoint projektu už neexistuje a repozitář neobsahoval migrace ani zálohu. Tento projekt proto obnovuje čistou databázi z verzovaných SQL migrací; původní účty a data se nepřenášejí.

1. V Supabase Dashboardu založ nový projekt a bezpečně si ulož databázové heslo.
2. Z kořene repozitáře spusť:

   ```sh
   npx supabase login
   npx supabase link --project-ref <novy-project-ref>
   npx supabase db push --dry-run
   npx supabase db push
   ```

3. V panelu **Connect** zkopíruj Project URL a publishable klíč `sb_publishable_…` do `.env`:

   ```dotenv
   SUPABASE_URL=https://<novy-project-ref>.supabase.co
   SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
   SENTRY_DSN=
   ```

4. V **Authentication → URL Configuration** nastav:

   - Site URL na produkční Netlify adresu;
   - Redirect URLs alespoň na produkční adresu a `http://localhost:8765/**`;
   - povolenou registraci e-mailem a potvrzení e-mailu.

5. Před veřejným spuštěním nastav vlastní SMTP. Výchozí Supabase mailer je určený jen pro vývoj a má nízké limity.

Schéma vytváří `profiles`, `coffee_logs`, automatický profil nového uživatele, RLS pravidla, Realtime publikaci a funkci pro bezpečné smazání poslední kávy. Produkční databázi neplň přes `--include-seed`; `seed.sql` je záměrně bez uživatelských dat.

> `npx supabase db reset --linked` maže vzdálenou databázi. V tomto projektu ho nepoužívej na produkčním prostředí.

## Před vydáním: účet a dokumenty

- V Nastavení lze účet smazat. Po nasazení poslední migrace funkce odstraní přihlašovací účet, profil i všechny záznamy kávy.
- Pro Google Play je vedle akce v aplikaci potřeba veřejná webová stránka pro žádost o smazání účtu. Tento repozitář ji nasazuje na `/delete-account`; její finální HTTPS URL vlož do Play Console.
- Veřejné podmínky a zásady ochrany soukromí jsou přímo v Netlify deployi na `/terms` a `/privacy`. Zdroje jsou v `web/`; při přidání analytiky, reklam, plateb nebo dalšího SDK text aktualizuj.
- CAF level je v aplikaci výslovně označený jako fiktivní herní ukazatel založený jen na čase od posledního záznamu. Není zdravotním měřením ani doporučením.

## Netlify

V nastavení webu přidej:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- volitelně `SENTRY_DSN`
- volitelně `SENTRY_AUTH_TOKEN`, pokud se mají uploadovat source mapy

Netlify používá `netlify_build.sh`, který stáhne přesně Flutter `3.38.5`, spustí `flutter pub get` a vytvoří release web build. SPA redirect je definovaný v `netlify.toml`.

### Vlastní subdoména a veřejné dokumenty

Před nasazením přidej v Netlify zamýšlenou subdoménu (např. `caffalert.example.cz`) jako Production domain a v DNS jejího parent doménového jména nastav CNAME podle hodnoty, kterou Netlify ukáže. Potom:

1. Doplň tuto HTTPS adresu jako Supabase **Site URL** a do **Redirect URLs** přidej `https://<tvoje-subdomena>/**`.
2. V Netlify zapni notifikaci pro formulář `caffalert-account-deletion` na `bujnovskyf@gmail.com`. Formulář je na `/delete-account` a slouží lidem, kteří už nemají přístup do aplikace.
3. Po prvním deployi otevři a ověř všechny veřejné cesty: `/privacy`, `/terms`, `/delete-account` a `/delete-account/sent/`.

Právní stránky jsou přímo součástí deploye a obsahují údaje provozovatele František Bujnovský, IČO 17800218. Před vydáním je vhodné nechat jejich konečné znění posoudit právníkem, zejména pokud později přidáš analytiku, reklamu, platby nebo jiné SDK.

Lokální release build:

```sh
flutter build web --release --dart-define-from-file=.env
```

## Testy a kontroly

```sh
flutter analyze
flutter test
npm run db:test       # vyžaduje spuštěný lokální Supabase
npm run db:lint       # vyžaduje spuštěný lokální Supabase
```

Flutter testy pokrývají časovač, denní a měsíční statistiky, návrat k předchozí kávě, provider a český/anglický onboarding. SQL test ověřuje schéma a oddělení dat dvou uživatelů pomocí RLS.

## Android

Android používá application ID `com.zachrana.app`. Debug APK sestavíš stejnými `dart-define` hodnotami:

```sh
flutter build apk --debug --dart-define-from-file=.env
```

Pro podepsaný release vytvoř mimo Git soubor `android/key.properties`:

```properties
storeFile=/absolutni/cesta/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Potom spusť:

```sh
flutter build appbundle --release --dart-define-from-file=.env
```

Bez `key.properties` se release varianta záměrně nepodepisuje debug klíčem.

## Konfigurace a bezpečnost

- `.env`, `sentry.properties`, Android keystory a `key.properties` jsou ignorované Gitem.
- Publishable klíč je určený pro klientské aplikace; ochranu dat zajišťují RLS pravidla.
- Supabase secret/service-role klíč nikdy nevkládej do Flutter aplikace ani do Netlify web buildu.
- Sentry je volitelné, v release nemá debug výpisy a neposílá výchozí osobní údaje.
