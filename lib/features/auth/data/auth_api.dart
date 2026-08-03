import 'package:dio/dio.dart';
import '../domain/auth_failure.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> requestOtp(String phoneNumber) {
    return _post(
      '/auth/request-otp',
      body: <String, Object?>{'phoneNumber': phoneNumber},
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String challengeId,
    required String code,
  }) {
    return _post(
      '/auth/verify-otp',
      body: <String, Object?>{'challengeId': challengeId, 'code': code},
    );
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) {
    return _post(
      '/auth/refresh-token',
      body: <String, Object?>{'refreshToken': refreshToken},
    );
  }

  Future<Map<String, dynamic>?> updateDisplayName({
    required String accessToken,
    required String displayName,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/auth/me',
        data: <String, Object?>{'displayName': displayName},
        options: Options(
          headers: <String, Object?>{'Authorization': 'Bearer $accessToken'},
        ),
      );
      return _unwrapOptionalProfile(response.data);
    } on DioException catch (error) {
      throw _failure(error);
    }
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, Object?> body,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw _failure(error);
    }
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic>? envelope) {
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const AuthFailure(
        code: 'INVALID_RESPONSE',
        message: 'Mikozi returned an unexpected response.',
      );
    }
    return data;
  }

  Map<String, dynamic>? _unwrapOptionalProfile(Map<String, dynamic>? envelope) {
    final data = envelope?['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (envelope != null && envelope['id'] is String) {
      return envelope;
    }
    return null;
  }

  AuthFailure _failure(DioException exception) {
    final responseData = exception.response?.data;
    if (responseData is Map<String, dynamic>) {
      final error = responseData['error'];
      if (error is Map<String, dynamic>) {
        final code = error['code'];
        final message = error['message'];
        if (code is String && message is String) {
          return AuthFailure(code: code, message: message);
        }
      }
    }
    return const AuthFailure(
      code: 'NETWORK_UNAVAILABLE',
      message: 'Unable to reach Mikozi. Check your connection and try again.',
    );
  }
}
