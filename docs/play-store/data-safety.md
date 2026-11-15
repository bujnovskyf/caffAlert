# CaffAlert: Data safety a sekce „Obsah aplikace“ v Play Console

Odpovědi pro **Play Console → Zásady → Obsah aplikace** (App content), verze 1.1.0+2. Vycházejí z kódu k 14. 11. 2026: `lib/`, `supabase/migrations/`, `android/app/src/main/AndroidManifest.xml`, sloučený manifest z buildu a konfigurace Sentry v `lib/main.dart`.

## Co aplikace skutečně zpracovává

| Data | Kde vzniká | Kam odchází | Proč |
| --- | --- | --- | --- |
| E-mail a heslo | registrace a přihlášení (`auth_screen.dart`) | Supabase Auth; heslo jen jako hash | účet, potvrzovací a resetovací e-maily |
| ID účtu (UUID) | Supabase Auth | Supabase (`profiles.id`, `coffee_logs.user_id`) | přiřazení záznamů k účtu |
| Zobrazované jméno (volitelné, 1–80 znaků) | Nastavení | Supabase `profiles.display_name` | oslovení v aplikaci |
| Časy zapsaných káv | tlačítko „Zapsat kávu“, widget „+ Káva“ (otevře aplikaci a zapíše kávu přihlášenému), úprava času | Supabase `coffee_logs.created_at` (+ Realtime) | CAF odpočet, statistiky, synchronizace |
| Diagnostika (jen když je v buildu `SENTRY_DSN`) | chyby na úrovni *error*, pády, 10 % výkonnostních trasování v release | Sentry (`sendDefaultPii = false`) | oprava chyb a stability |
| Jen v telefonu | jazyk, onboarding, volba upozornění, poslední čas kávy pro widget, deduplikace tapů z widgetu, naplánované upozornění, lokální log `app_logs.txt` (v release jen varování a chyby, `lib/file_log_output.dart`; připisuje se, automaticky se nepromazává, zmizí s odinstalací nebo vymazáním dat) | **nikam** | chod aplikace, dohledání chyb |

Nepoužívá se: reklamy, reklamní ID, analytika (GA4 / Firebase), poloha, kontakty, fotky, platby, Health Connect. Upozornění „CAF na nule“ je lokální (`flutter_local_notifications`, inexact plánování) a nic neposílá na server.

Data, která nikdy neopustí zařízení, Google za „shromažďovaná“ nepovažuje, takže se do formuláře neuvádějí. Supabase a Sentry jsou **zpracovatelé** (service providers) jednající podle pokynů provozovatele, takže předání jim se **neuvádí jako sdílení**.

### Sentry: rozhodni před vyplněním

Lokální `.env` má `SENTRY_DSN` prázdný, takže Android build z něj Sentry **nespouští**. Pro formulář platí stav, který půjde do obchodu:

- **Varianta A (doporučená pro 1.1.0): DSN v Android buildu prázdný.** Sekci *Informace o aplikaci a výkonu* a *ID zařízení nebo jiná ID* nevyplňuj.
- **Varianta B: DSN vyplněný.** Přidej řádky označené „jen B“ níže. V nastavení projektu Sentry zapni *Prevent Storing of IP Addresses* a nech `sendDefaultPii = false`.

Kdykoli se varianta změní, Data safety je nutné aktualizovat **dřív**, než vyjde build s jiným chováním.

## Data safety: odpovědi do formuláře

### Shromažďování a zabezpečení

| Otázka | Odpověď |
| --- | --- |
| Shromažďuje nebo sdílí aplikace některý z požadovaných typů dat? | **Ano** |
| Jsou všechna data shromážděná aplikací šifrovaná při přenosu? | **Ano** (HTTPS / WSS na Supabase, HTTPS na Sentry) |
| Které způsoby vytvoření účtu aplikace podporuje? | **Uživatelské jméno a heslo** (e-mail + heslo); bez OAuth a bez přihlášení přes třetí strany |
| Odkaz na smazání účtu | **https://caff-alert.netlify.app/delete-account** |
| Mohou uživatelé požádat o smazání části dat bez smazání účtu? | **Ano**: nedávné záznamy kávy smaže uživatel v aplikaci, jméno může vymazat; ostatní na e-mail z `/privacy` |
| Nezávislé bezpečnostní posouzení (MASA) | **Ne** |
| Dodržuje zásady pro rodiny (Families) | **Ne**, aplikace není určená dětem |

### Typy dat

| Kategorie → typ | Shromážděno | Sdíleno | Dočasné zpracování | Povinné / volitelné | Účel |
| --- | --- | --- | --- | --- | --- |
| Osobní údaje → **E-mailová adresa** | Ano | Ne | Ne | Povinné | Funkčnost aplikace, Správa účtu |
| Osobní údaje → **ID uživatele** (ID účtu Supabase) | Ano | Ne | Ne | Povinné | Funkčnost aplikace, Správa účtu |
| Osobní údaje → **Jméno** (zobrazované jméno) | Ano | Ne | Ne | Volitelné | Funkčnost aplikace, Personalizace |
| Aktivita v aplikaci → **Jiný obsah vytvořený uživatelem** (časy zapsaných káv) | Ano | Ne | Ne | Volitelné | Funkčnost aplikace |
| Informace o aplikaci a výkonu → **Protokoly o selhání** — *jen B* | Ano | Ne | Ne | Povinné | Analytika |
| Informace o aplikaci a výkonu → **Diagnostika** — *jen B* | Ano | Ne | Ne | Povinné | Analytika |
| ID zařízení nebo jiná ID → **ID zařízení nebo jiná ID** (náhodné instalační ID Sentry) — *jen B* | Ano | Ne | Ne | Povinné | Analytika |

Poznámky k volbám:

- Časy káv dávám do *Jiný obsah vytvořený uživatelem*, protože je uživatel vědomě zapisuje sám. **Ne** do *Zdraví a fitness* (aplikace neukládá dávku, druh nápoje ani nic zdravotního) a ne do *Interakce s aplikací* (nejde o měření chování).
- Heslo Google v Data safety jako samostatný typ nevyžaduje; je součástí účtu.
- IP adresy zapisují servery Supabase (auth logy) a případně Sentry. Formulář je jako typ nemá; jako *Přibližnou polohu* by se uváděly, jen kdyby z nich aplikace polohu odvozovala, a to nedělá.

## Ostatní deklarace v „Obsahu aplikace“

### Zásady ochrany soukromí

URL: **https://caff-alert.netlify.app/privacy** (česká verze `/cs/privacy`). Odkaz je i **přímo v aplikaci**, jak chtějí zásady Play: Nastavení → Právní informace → Zásady ochrany soukromí / Podmínky použití (`lib/settings_screen.dart`, absolutní URL, v češtině `/cs/…`).

### Reklamy

**Ne, aplikace neobsahuje reklamy.**

### Reklamní ID

**Ne.** Sloučený manifest nemá `com.google.android.gms.permission.AD_ID` a žádná knihovna reklamní ID nečte.

### Přístup do aplikace (App access)

**Všechny nebo některé funkce jsou omezené** → přidat pokyny:

- Název: `Testovací účet CaffAlert`
- Uživatelské jméno: `{{E-MAIL TESTOVACÍHO ÚČTU}}`
- Heslo: `{{HESLO}}`
- Další informace (vložit anglicky):

```text
Sign in with the email and password above (no 2FA, no OTP). The account is already confirmed and contains a few sample coffee logs.
1) Main screen: tap "Log a coffee" – CAF level jumps to 100% and drops to zero over 4 hours; the screen shows "CAF hits zero at …". CAF is a fictional game metric, not a caffeine or health measurement, and the app never suggests when or how much to drink.
2) Stats tab: today / month / total counts, first and last coffee, average interval.
3) Settings: display name, language (CZ/EN), optional "Notify me when CAF hits zero" (asks for notification permission on Android 13+; the reminder is inexact and may arrive late), Privacy Policy and Terms of Use links, Delete account.
4) Home-screen widget: long-press the home screen > Widgets > CaffAlert. The default size is 4x2 with a "+ Coffee" button and the time CAF hits zero. Tapping "+ Coffee" opens the app and logs one coffee (only when signed in). The widget can be resized to 2x2, which has no button.
Please do not delete this test account; you can create your own account in the app to test deletion.
```

**František musí založit testovací účet** (vlastní e-mail, např. alias Gmailu), potvrdit e-mail, zapsat pár káv a heslo nesdílet nikde jinde. Účet nesmí mít dvoufázové ověření ani vazbu na konkrétní zařízení. Když heslo změníš, změň ho i v Play Console.

### Hodnocení obsahu (IARC dotazník)

- E-mail pro IARC: `{{KONTAKTNI_EMAIL}}`
- Kategorie: **Všechny ostatní typy aplikací** (ne hra, ne sociální síť, ne zpravodajství)
- Násilí, sex, vulgarity, strach: **Ne**
- Drogy, alkohol, tabák: **Ne** (kofein a káva mezi kontrolované látky nepatří)
- Hazard a simulovaný hazard: **Ne**
- Interakce mezi uživateli, sdílení obsahu: **Ne** (každý vidí jen svá data, RLS)
- Sdílí aplikace aktuální polohu uživatele: **Ne**
- Nákupy digitálního zboží: **Ne**
- Neomezený přístup k internetu (vestavěný prohlížeč): **Ne**
- Očekávaný výsledek: PEGI 3 / ESRB Everyone / USK 0

### Cílová skupina a obsah

- Věkové skupiny: **18 a více** (konzervativně: text zmiňuje energy drinky a kofein; aplikace není pro děti). Varianta *16–17 + 18+* je obhajitelná, ale zbytečně otevírá otázky zásad pro rodiny.
- Mohla by aplikace neúmyslně lákat děti? **Ne**
- Nic dalšího se při 18+ nevyplňuje.

### Deklarace zdravotních aplikací (Health apps)

Vyplňuje ji **každá** aplikace. Odpověď: **„Moje aplikace neposkytuje žádné zdravotní funkce“** (*My app doesn't provide any health features*).

Proč: CAF je fiktivní herní odpočet z času posledního zápisu. Aplikace neukládá dávky, druhy nápojů ani cíle, neradí s výživou a nepracuje s Health Connect. Nejbližší kategorie *Výživa a správa hmotnosti* zahrnuje sledování stravy a cíle; CaffAlert ukládá jen časy. Texty obchodu i aplikace to výslovně říkají („CAF je hra, ne měření“). Kdyby recenze přesto trvala na zdravotní kategorii, zvolit *Výživa a správa hmotnosti* bez dalších změn v aplikaci.

### Finanční funkce, vládní aplikace, zprávy, COVID-19

Žádné / **Ne**.

### Oprávnění

Ve sloučeném manifestu jsou tato oprávnění (ověřeno na debug buildu 14. 11. 2026, po release buildu zkontroluj znovu, viz `RELEASE.md`):

| Oprávnění | Odkud | Proč | Deklarace v Console |
| --- | --- | --- | --- |
| `INTERNET` | aplikace | Supabase přihlášení, data, Realtime | ne |
| `POST_NOTIFICATIONS` | `flutter_local_notifications` | volitelné upozornění „CAF na nule“, ptá se až po zapnutí v Nastavení | ne |
| `VIBRATE` | `flutter_local_notifications` | vibrace upozornění | ne |
| `RECEIVE_BOOT_COMPLETED` | přímo `AndroidManifest.xml` (boot receiver `ScheduledNotificationBootReceiver` z `flutter_local_notifications`); deklaruje ho i `androidx.work` (přes `home_widget`) | obnovení naplánovaného upozornění „CAF na nule“ po restartu nebo aktualizaci aplikace; WorkManager obnovuje své úlohy | ne |
| `WAKE_LOCK`, `ACCESS_NETWORK_STATE` | `androidx.work` | běh úloh WorkManageru | ne |
| `FOREGROUND_SERVICE` | `androidx.work` (služba `SystemForegroundService` bez typu) | interní služba WorkManageru | ne (deklaraci typu FGS vyžaduje jen `FOREGROUND_SERVICE_*`; kdyby se Console přesto zeptala, popsat, že aplikace foreground službu sama nespouští) |

**Nejsou tam:** `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM` (upozornění je záměrně nepřesné), poloha, kamera, kontakty, úložiště, `AD_ID`. Deklarace přesných budíků se tedy nevyplňuje.

## Soulad `/privacy` s kódem

Stav k 14. 11. 2026, ověřeno v `lib/settings_screen.dart`, `lib/main.dart`, `lib/file_log_output.dart` a `web/privacy` (EN i CS). Datum účinnosti zásad i podmínek je 14. 11. 2026.

**Vyřešeno:**

1. ~~Odkaz na zásady v Android aplikaci~~: Nastavení → Právní informace má odkazy na zásady i podmínky (absolutní URL, podle jazyka `/cs/…`).
2. ~~Upozornění a widget v zásadách~~: `/privacy` bod 1 má odstavec o volitelném upozornění (včetně `POST_NOTIFICATIONS` a jeho odvolání) a odstavec o datech uložených jen v zařízení (widget, značky proti dvojímu zápisu, volby, lokální chybový log `app_logs.txt`).
3. ~~Sentry dělá víc než hlášení chyb~~: bod 3 zmiňuje vzorek výkonnostních dat a náhodný identifikátor instalace.
4. ~~Oprávnění k oznámením~~: viz bod 2.
5. ~~Zálohy a logy poskytovatelů~~: bod 5 uvádí, že kopie mohou krátce zůstat v zálohách a logech Supabase.
6. ~~Věk~~: podmínky (bod 2) i zásady (bod 8) uvádějí 18+.
7. ~~Sentry `release` natvrdo~~: `lib/main.dart` ho skládá z `package_info_plus` (`caff_alert@{verze}+{build}`).

**Otevřené:**

1. ~~E-mailová služba~~: od 15. 11. 2026 posílá Supabase e-maily přes vlastní SMTP Hostinger (`noreply@frantisekbujnovsky.com`, DKIM/SPF/DMARC v pořádku); zásady (bod 3, EN i CS) Hostinger uvádějí, platné od 15. 11. 2026.
2. **Distribuce přes Google Play.** Volitelné: zmínit, že při stažení z Google Play zpracovává údaje o instalaci Google jako samostatný správce (na Google zásady odkázat).
