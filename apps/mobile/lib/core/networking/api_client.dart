import 'api_config.dart';

/// Interface defining core HTTP client contract.
abstract class ApiClient {
  Future<dynamic> get(String path,
      {Map<String, String>? headers, Map<String, dynamic>? queryParameters});
  Future<dynamic> post(String path,
      {dynamic body, Map<String, String>? headers});
}

/// Default placeholder implementation for the ApiClient contract.
class MockApiClient implements ApiClient {
  final String baseUrl;

  const MockApiClient({this.baseUrl = ApiConfig.baseUrl});

  @override
  Future<dynamic> get(String path,
      {Map<String, String>? headers,
      Map<String, dynamic>? queryParameters}) async {
    // Placeholder to be replaced when real networking is integrated
    return <String, dynamic>{};
  }

  @override
  Future<dynamic> post(String path,
      {dynamic body, Map<String, String>? headers}) async {
    // Placeholder to be replaced when real networking is integrated
    return <String, dynamic>{'success': true};
  }
}
