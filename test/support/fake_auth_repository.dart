import 'dart:async';

import 'package:mikozi_mobile/features/auth/domain/auth_profile.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_repository.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_session.dart';
import 'package:mikozi_mobile/features/auth/domain/otp_challenge.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.restoredSession,
    this.requestOtpCompleter,
    this.requestOtpError,
  });

  AuthSession? restoredSession;
  final Completer<OtpChallenge>? requestOtpCompleter;
  final Object? requestOtpError;
  String? requestedPhoneNumber;
  String? verifiedCode;
  String? savedName;
  bool cleared = false;

  @override
  Future<void> clearSession() async {
    cleared = true;
    restoredSession = null;
  }

  @override
  Future<OtpChallenge> requestOtp(String phoneNumber) async {
    requestedPhoneNumber = phoneNumber;
    if (requestOtpError case final error?) {
      throw error;
    }
    if (requestOtpCompleter case final completer?) {
      return completer.future;
    }
    return OtpChallenge(
      id: '8f64f28e-e913-4f4c-8530-a2e7f8ee9652',
      phoneNumber: phoneNumber,
      expiresAt: DateTime.utc(2030),
      resendAfterSeconds: 60,
    );
  }

  @override
  Future<AuthSession?> restore() async => restoredSession;

  @override
  Future<AuthSession> updateDisplayName({
    required AuthSession session,
    required String displayName,
  }) async {
    savedName = displayName;
    restoredSession = session.copyWith(
      profile: session.profile.copyWith(displayName: displayName),
    );
    return restoredSession!;
  }

  @override
  Future<AuthSession> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    verifiedCode = code;
    restoredSession = session(displayName: null);
    return restoredSession!;
  }
}

AuthSession session({required String? displayName}) {
  return AuthSession(
    profile: AuthProfile(
      id: '35b38593-a653-454c-b88f-07e1b34c0cd1',
      phoneNumber: '265991234567',
      displayName: displayName,
      preferredLanguage: 'en',
    ),
    tokens: AuthTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      accessExpiresAt: DateTime.utc(2030),
      refreshExpiresAt: DateTime.utc(2031),
    ),
  );
}
