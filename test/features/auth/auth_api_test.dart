import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/auth/data/auth_api.dart';
import 'package:mikozi_mobile/features/auth/data/auth_session_store.dart';
import 'package:mikozi_mobile/features/auth/data/remote_auth_repository.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_failure.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_session.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  test('request OTP uses the versioned auth contract', () async {
    final adapter = _AuthAdapter(
      statusCode: 201,
      body: <String, Object?>{
        'data': <String, Object?>{
          'challengeId': 'challenge-id',
          'expiresAt': '2030-01-01T00:00:00.000Z',
          'resendAfterSeconds': 60,
        },
      },
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://mikozi.test/api/v1'))
      ..httpClientAdapter = adapter;

    final response = await AuthApi(dio).requestOtp('265991234567');

    expect(adapter.lastOptions?.path, '/auth/request-otp');
    expect(
      adapter.lastOptions?.uri,
      Uri.parse('https://mikozi.test/api/v1/auth/request-otp'),
    );
    expect(adapter.lastOptions?.data, <String, Object?>{
      'phoneNumber': '265991234567',
    });
    expect(response['challengeId'], 'challenge-id');
  });

  test('backend auth failures keep their stable code and message', () async {
    final adapter = _AuthAdapter(
      statusCode: 400,
      body: <String, Object?>{
        'error': <String, Object?>{
          'code': 'OTP_INVALID',
          'message': 'The verification code is incorrect.',
        },
      },
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://mikozi.test/api/v1'))
      ..httpClientAdapter = adapter;

    expect(
      () => AuthApi(dio).verifyOtp(challengeId: 'challenge-id', code: '000000'),
      throwsA(
        isA<AuthFailure>()
            .having((failure) => failure.code, 'code', 'OTP_INVALID')
            .having(
              (failure) => failure.message,
              'message',
              'The verification code is incorrect.',
            ),
      ),
    );
  });

  test(
    'successful profile write is not rejected for a partial response',
    () async {
      final adapter = _AuthAdapter(
        statusCode: 200,
        body: <String, Object?>{
          'data': <String, Object?>{'updated': true},
        },
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://mikozi.test/api/v1'))
        ..httpClientAdapter = adapter;
      final store = _MemorySessionStore();
      final repository = RemoteAuthRepository(AuthApi(dio), store);

      final updated = await repository.updateDisplayName(
        session: session(displayName: null),
        displayName: 'Chikondi',
      );

      expect(adapter.lastOptions?.method, 'PATCH');
      expect(adapter.lastOptions?.path, '/auth/me');
      expect(updated.profile.displayName, 'Chikondi');
      expect(store.saved?.profile.displayName, 'Chikondi');
    },
  );
}

class _MemorySessionStore implements AuthSessionStore {
  AuthSession? saved;

  @override
  Future<void> delete() async {
    saved = null;
  }

  @override
  Future<AuthSession?> read() async => saved;

  @override
  Future<void> write(AuthSession session) async {
    saved = session;
  }
}

class _AuthAdapter implements HttpClientAdapter {
  _AuthAdapter({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, Object?> body;
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
