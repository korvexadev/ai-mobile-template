import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/auth_profile.dart';
import '../domain/auth_session.dart';

abstract interface class AuthSessionStore {
  Future<AuthSession?> read();

  Future<void> write(AuthSession session);

  Future<void> delete();
}

class SecureAuthSessionStore implements AuthSessionStore {
  SecureAuthSessionStore(this._storage);

  static const _sessionKey = 'mikozi.reader.session.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthSession?> read() async {
    final value = await _storage.read(key: _sessionKey);
    if (value == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return _sessionFromJson(decoded);
    } on FormatException {
      await delete();
      return null;
    } on TypeError {
      await delete();
      return null;
    }
  }

  @override
  Future<void> write(AuthSession session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(_sessionToJson(session)),
    );
  }

  @override
  Future<void> delete() => _storage.delete(key: _sessionKey);

  Map<String, Object?> _sessionToJson(AuthSession session) {
    return <String, Object?>{
      'profile': <String, Object?>{
        'id': session.profile.id,
        'phoneNumber': session.profile.phoneNumber,
        'displayName': session.profile.displayName,
        'preferredLanguage': session.profile.preferredLanguage,
      },
      'tokens': <String, Object?>{
        'accessToken': session.tokens.accessToken,
        'refreshToken': session.tokens.refreshToken,
        'accessExpiresAt': session.tokens.accessExpiresAt.toIso8601String(),
        'refreshExpiresAt': session.tokens.refreshExpiresAt.toIso8601String(),
      },
    };
  }

  AuthSession _sessionFromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>;
    final tokens = json['tokens'] as Map<String, dynamic>;
    return AuthSession(
      profile: AuthProfile(
        id: profile['id'] as String,
        phoneNumber: profile['phoneNumber'] as String,
        displayName: profile['displayName'] as String?,
        preferredLanguage: profile['preferredLanguage'] as String,
      ),
      tokens: AuthTokens(
        accessToken: tokens['accessToken'] as String,
        refreshToken: tokens['refreshToken'] as String,
        accessExpiresAt: DateTime.parse(
          tokens['accessExpiresAt'] as String,
        ).toUtc(),
        refreshExpiresAt: DateTime.parse(
          tokens['refreshExpiresAt'] as String,
        ).toUtc(),
      ),
    );
  }
}
