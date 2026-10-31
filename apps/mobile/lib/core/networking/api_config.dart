/// Public API configuration for the mobile client.
///
/// Cloudflare account credentials and service-account tokens must never be
/// included in the mobile application. Override this URL per build with:
/// `--dart-define=GARBLO_API_BASE_URL=https://api.example.com`.
class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'GARBLO_API_BASE_URL',
    defaultValue: 'https://api.phamtanph.uk',
  );

  const ApiConfig._();
}
