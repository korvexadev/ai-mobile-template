import 'package:mikozi_mobile/features/auth/domain/auth_failure.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_profile.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_session.dart';
import 'package:mikozi_mobile/features/auth/domain/otp_challenge.dart';

abstract final class AuthResponseMapper {
  static OtpChallenge challenge(
    Map<String, dynamic> json, {
    required String phoneNumber,
  }) {
    return OtpChallenge(
      id: _string(json, 'challengeId'),
      phoneNumber: phoneNumber,
      expiresAt: _date(json, 'expiresAt'),
      resendAfterSeconds: _integer(json, 'resendAfterSeconds'),
    );
  }

  static AuthSession session(Map<String, dynamic> json) {
    return AuthSession(
      profile: profile(_map(json, 'profile')),
      tokens: tokens(_map(json, 'tokens')),
    );
  }

  static AuthProfile profile(Map<String, dynamic> json) {
    return AuthProfile(
      id: _string(json, 'id'),
      phoneNumber: _string(json, 'phoneNumber'),
      displayName: _nullableString(json, 'displayName'),
      preferredLanguage: _string(json, 'preferredLanguage'),
    );
  }

  static AuthTokens tokens(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: _string(json, 'accessToken'),
      refreshToken: _string(json, 'refreshToken'),
      accessExpiresAt: _date(json, 'accessExpiresAt'),
      refreshExpiresAt: _date(json, 'refreshExpiresAt'),
    );
  }

  static Map<String, dynamic> _map(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw _invalid();
  }

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }
    throw _invalid();
  }

  static int _integer(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    throw _invalid();
  }

  static String? _nullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value is String) {
      return value as String?;
    }
    throw _invalid();
  }

  static DateTime _date(Map<String, dynamic> json, String key) {
    try {
      return DateTime.parse(_string(json, key)).toUtc();
    } on FormatException {
      throw _invalid();
    }
  }

  static AuthFailure _invalid() {
    return const AuthFailure(
      code: 'INVALID_RESPONSE',
      message: 'Mikozi returned an unexpected response.',
    );
  }
}
