class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    this.sentryDsn = '',
  });

  factory AppConfig.fromEnvironment() {
    const url = String.fromEnvironment('SUPABASE_URL');
    const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');

    final parsedUrl = Uri.tryParse(url);
    if (parsedUrl == null ||
        !parsedUrl.hasAuthority ||
        (parsedUrl.scheme != 'https' && parsedUrl.scheme != 'http')) {
      throw const AppConfigException(
        'SUPABASE_URL is missing or is not a valid HTTP(S) URL.',
      );
    }
    if (publishableKey.trim().isEmpty) {
      throw const AppConfigException(
        'SUPABASE_PUBLISHABLE_KEY is missing.',
      );
    }

    return const AppConfig(
      supabaseUrl: url,
      supabasePublishableKey: publishableKey,
      sentryDsn: sentryDsn,
    );
  }

  final String supabaseUrl;
  final String supabasePublishableKey;
  final String sentryDsn;
}

class AppConfigException implements Exception {
  const AppConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
