// Generated-contract boundary for GET /api/v1/reader/homepage.
// Regenerate this layer when openapi/mikozi.v1.json changes.
import 'package:dio/dio.dart';

class MikoziApiClient {
  MikoziApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getReaderHomepage() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reader/homepage',
      options: Options(headers: const {'Cache-Control': 'no-cache'}),
    );
    final envelope = response.data;
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid homepage response.');
    }
    return data;
  }

  Future<Map<String, dynamic>> getReaderArticle({
    required String slug,
    required String accessToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reader/articles/slug/${Uri.encodeComponent(slug)}',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Cache-Control': 'no-cache',
        },
      ),
    );
    final envelope = response.data;
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid article response.');
    }
    return data;
  }

  Future<Map<String, dynamic>> getReaderEntitlement({
    required String accessToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/subscriptions/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Cache-Control': 'no-cache',
        },
      ),
    );
    final envelope = response.data;
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid subscription response.');
    }
    return data;
  }

  Future<Map<String, dynamic>> getReaderCategoryArticles({
    required String slug,
    int limit = 30,
    int offset = 0,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reader/categories/${Uri.encodeComponent(slug)}/articles',
      queryParameters: {'limit': limit, 'offset': offset},
      options: Options(headers: const {'Cache-Control': 'no-cache'}),
    );
    final envelope = response.data;
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid category articles response.');
    }
    return data;
  }
}
