import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caff_alert/widget_launch_handler.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Uri tap(String id, {int? at}) => Uri.parse(
        'caffalert://widget/log?tap=$id&at=${at ?? DateTime.now().millisecondsSinceEpoch}',
      );

  test('concurrent initial launch and stream delivery claim only once',
      () async {
    final uri = tap('same-tap');
    final results = await Future.wait([
      WidgetLaunchHandler.claim(uri, userId: 'user'),
      WidgetLaunchHandler.claim(uri, userId: 'user'),
    ]);
    expect(results, [true, false]);
    // Persisted claims also protect a recreated shell (and a changed account).
    expect(await WidgetLaunchHandler.claim(uri, userId: 'other-user'), false);
    expect(
        await WidgetLaunchHandler.claim(tap('new-tap'), userId: 'user'), true);
  });

  test('body taps, signed-out launches and stale intents cannot log', () async {
    expect(
        await WidgetLaunchHandler.claim(Uri.parse('caffalert://widget/open'),
            userId: 'user'),
        false);
    final uri = tap('signed-out');
    expect(await WidgetLaunchHandler.claim(uri, userId: null), false);
    expect(
        await WidgetLaunchHandler.claim(
            tap('old',
                at: DateTime.now()
                    .subtract(const Duration(minutes: 3))
                    .millisecondsSinceEpoch),
            userId: 'user'),
        false);
    expect(
        await WidgetLaunchHandler.claim(Uri.parse('caffalert://widget/log'),
            userId: 'user'),
        false);
  });

  test('a tap made while signed out is dropped, not logged after sign-in',
      () async {
    final uri = tap('while-signed-out');
    expect(await WidgetLaunchHandler.claim(uri, userId: null), false);
    // The same launch Intent is replayed once the user has signed in.
    expect(await WidgetLaunchHandler.claim(uri, userId: 'user'), false);
  });

  test('taps from before the sign-in moment are dropped', () async {
    final signedInAt = DateTime.now();
    final before = tap(
      'before-sign-in',
      at: signedInAt
          .subtract(const Duration(seconds: 20))
          .millisecondsSinceEpoch,
    );
    expect(
      await WidgetLaunchHandler.claim(before,
          userId: 'user', notBefore: signedInAt),
      false,
    );
    expect(
      await WidgetLaunchHandler.claim(before, userId: 'user'),
      false,
      reason: 'already claimed as dropped',
    );
    final after = tap(
      'after-sign-in',
      at: signedInAt.add(const Duration(seconds: 1)).millisecondsSinceEpoch,
    );
    expect(
      await WidgetLaunchHandler.claim(after,
          userId: 'user', notBefore: signedInAt),
      true,
    );
  });
}
