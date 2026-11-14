import 'package:flutter/foundation.dart';

/// Deep link that brings email confirmation and password reset links back
/// into the Android app. It must match the intent filter in
/// `android/app/src/main/AndroidManifest.xml` and be allowed in Supabase Auth
/// (URL Configuration → Redirect URLs).
const nativeAuthRedirectUrl =
    'com.frantisekbujnovsky.caffalert://login-callback';

/// Where Supabase should send the user after they open an auth email link.
///
/// The web app returns to its own origin. Android returns through the custom
/// scheme deep link, which supabase_flutter turns into a session. Other
/// platforms have no registered scheme yet and fall back to the Site URL.
String? authRedirectUrl({
  bool isWeb = kIsWeb,
  TargetPlatform? platform,
  Uri? currentUri,
}) {
  if (isWeb) return (currentUri ?? Uri.base).origin;
  if ((platform ?? defaultTargetPlatform) == TargetPlatform.android) {
    return nativeAuthRedirectUrl;
  }
  return null;
}
