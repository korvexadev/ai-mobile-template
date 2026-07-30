// Generated-contract boundary for GET /api/v1/reader/homepage.
// Regenerate this layer when openapi/mikozi.v1.json changes.
import 'package:dio/dio.dart';

class MikoziApiClient {
  MikoziApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getReaderHomepage() async {
    final response = await _dio.get<Map<String, dynamic>>('/reader/homepage');
    final envelope = response.data;
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid homepage response.');
    }
    return data;
  }
}
