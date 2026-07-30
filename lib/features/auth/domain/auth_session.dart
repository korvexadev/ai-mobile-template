import 'auth_profile.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;

  bool accessIsValidAt(DateTime time) {
    return accessExpiresAt.isAfter(time.add(const Duration(seconds: 30)));
  }

  bool refreshIsValidAt(DateTime time) => refreshExpiresAt.isAfter(time);
}

class AuthSession {
  const AuthSession({required this.profile, required this.tokens});

  final AuthProfile profile;
  final AuthTokens tokens;

  bool get needsName => profile.needsName;

  AuthSession copyWith({AuthProfile? profile, AuthTokens? tokens}) {
    return AuthSession(
      profile: profile ?? this.profile,
      tokens: tokens ?? this.tokens,
    );
  }
}
