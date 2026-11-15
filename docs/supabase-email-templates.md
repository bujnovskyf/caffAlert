# Supabase auth email templates (CZ + EN)

Production project: Authentication → Emails → Templates. Each email is bilingual (Czech first, English below), because Supabase sends one template to every user. Sender: `CaffAlert <noreply@frantisekbujnovsky.com>` via Hostinger SMTP.

## Confirm signup

Subject:

```text
Potvrď svůj účet CaffAlert / Confirm your CaffAlert account
```

Body:

```html
<div style="font-family:Arial,Helvetica,sans-serif;color:#35241D;max-width:480px">
  <h2 style="margin:0 0 12px">Vítej v CaffAlertu ☕</h2>
  <p>Potvrď prosím svůj e-mail, ať se můžeš přihlásit:</p>
  <p><a href="{{ .ConfirmationURL }}" style="display:inline-block;background:#35241D;color:#FFFBF7;padding:12px 20px;border-radius:10px;text-decoration:none;font-weight:bold">Potvrdit e-mail</a></p>
  <p style="color:#6D4938;font-size:13px">Pokud jsi o účet nežádal(a), tento e-mail ignoruj.</p>
  <hr style="border:none;border-top:1px solid #F4E9DE;margin:20px 0">
  <h2 style="margin:0 0 12px">Welcome to CaffAlert ☕</h2>
  <p>Please confirm your email so you can sign in:</p>
  <p><a href="{{ .ConfirmationURL }}" style="color:#6D4938;font-weight:bold">Confirm email</a></p>
  <p style="color:#6D4938;font-size:13px">If you didn't ask for an account, you can ignore this email.</p>
</div>
```

## Reset password

Subject:

```text
Obnova hesla CaffAlert / Reset your CaffAlert password
```

Body:

```html
<div style="font-family:Arial,Helvetica,sans-serif;color:#35241D;max-width:480px">
  <h2 style="margin:0 0 12px">Obnova hesla</h2>
  <p>Klepni na tlačítko a nastav si nové heslo:</p>
  <p><a href="{{ .ConfirmationURL }}" style="display:inline-block;background:#35241D;color:#FFFBF7;padding:12px 20px;border-radius:10px;text-decoration:none;font-weight:bold">Nastavit nové heslo</a></p>
  <p style="color:#6D4938;font-size:13px">Pokud jsi o obnovu nežádal(a), e-mail ignoruj. Tvoje heslo zůstává beze změny.</p>
  <hr style="border:none;border-top:1px solid #F4E9DE;margin:20px 0">
  <h2 style="margin:0 0 12px">Reset your password</h2>
  <p>Tap the link to set a new password:</p>
  <p><a href="{{ .ConfirmationURL }}" style="color:#6D4938;font-weight:bold">Set a new password</a></p>
  <p style="color:#6D4938;font-size:13px">If you didn't ask for a reset, ignore this email. Your password stays the same.</p>
</div>
```

## Change email address

Subject:

```text
Potvrď změnu e-mailu v CaffAlertu / Confirm your new CaffAlert email
```

Body:

```html
<div style="font-family:Arial,Helvetica,sans-serif;color:#35241D;max-width:480px">
  <h2 style="margin:0 0 12px">Změna e-mailu</h2>
  <p>Potvrď změnu e-mailu z {{ .Email }} na {{ .NewEmail }}:</p>
  <p><a href="{{ .ConfirmationURL }}" style="display:inline-block;background:#35241D;color:#FFFBF7;padding:12px 20px;border-radius:10px;text-decoration:none;font-weight:bold">Potvrdit změnu</a></p>
  <hr style="border:none;border-top:1px solid #F4E9DE;margin:20px 0">
  <h2 style="margin:0 0 12px">Email change</h2>
  <p>Confirm the change from {{ .Email }} to {{ .NewEmail }}:</p>
  <p><a href="{{ .ConfirmationURL }}" style="color:#6D4938;font-weight:bold">Confirm change</a></p>
</div>
```
