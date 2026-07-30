/// Central REST addressing for the Mikozi mobile application.
///
/// Change [origin] when the development tunnel changes. All REST clients use
/// [baseUrl], so endpoint paths remain independent from the active host.
abstract final class ApiConstants {
  static const String origin =
      'https://losses-gdp-hurricane-start.trycloudflare.com';
  static const String versionPath = '/api/v1';
  static const String baseUrl = '$origin$versionPath';
}
