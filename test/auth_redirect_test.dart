import 'package:caff_alert/auth_redirect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web returns to the current origin', () {
    expect(
      authRedirectUrl(
        isWeb: true,
        currentUri: Uri.parse('https://caffalert.example/app?x=1'),
      ),
      'https://caffalert.example',
    );
  });

  test('android returns through the app deep link', () {
    expect(
      authRedirectUrl(isWeb: false, platform: TargetPlatform.android),
      nativeAuthRedirectUrl,
    );
    expect(
      Uri.parse(nativeAuthRedirectUrl),
      isA<Uri>()
          .having(
              (uri) => uri.scheme, 'scheme', 'com.frantisekbujnovsky.caffalert')
          .having((uri) => uri.host, 'host', 'login-callback'),
    );
  });

  test('platforms without a registered scheme fall back to the Site URL', () {
    expect(authRedirectUrl(isWeb: false, platform: TargetPlatform.iOS), isNull);
  });
}
