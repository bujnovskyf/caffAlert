import 'package:shared_preferences/shared_preferences.dart';

/// Claims native widget taps durably before mutation. A crash can lose a tap,
/// but replaying an Activity intent must never create another coffee.
abstract final class WidgetLaunchHandler {
  static const _key = 'claimed_widget_coffee_taps';
  static Future<void> _queue = Future.value();

  /// True when [uri] is a fresh, unclaimed "+ Coffee" tap that may log now.
  ///
  /// A tap made while signed out ([userId] null) or before [notBefore] (the
  /// moment of sign-in) is claimed as well, but returns false: it is dropped
  /// and never logged after a later sign-in.
  static Future<bool> claim(
    Uri? uri, {
    required String? userId,
    DateTime? notBefore,
  }) {
    final result = _queue.then((_) => _claim(uri, userId, notBefore));
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  static Future<bool> _claim(
    Uri? uri,
    String? userId,
    DateTime? notBefore,
  ) async {
    if (uri == null ||
        uri.scheme != 'caffalert' ||
        uri.host != 'widget' ||
        uri.path != '/log') {
      return false;
    }
    final tap = uri.queryParameters['tap'];
    final at = int.tryParse(uri.queryParameters['at'] ?? '');
    final now = DateTime.now().millisecondsSinceEpoch;
    if (tap == null ||
        tap.isEmpty ||
        at == null ||
        now - at > const Duration(minutes: 2).inMilliseconds ||
        at > now + 10000) {
      return false;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final claims = (preferences.getStringList(_key) ?? []).where((value) {
      final timestamp = int.tryParse(value.split(':').first);
      return timestamp != null && now - timestamp < 180000;
    }).toList();
    final claim = '$at:$tap';
    if (claims.contains(claim)) return false;
    claims.add(claim);
    final saved = await preferences.setStringList(_key, claims);
    final signedOut = userId == null || userId.isEmpty;
    final beforeSignIn =
        notBefore != null && at < notBefore.millisecondsSinceEpoch;
    return saved && !signedOut && !beforeSignIn;
  }
}
