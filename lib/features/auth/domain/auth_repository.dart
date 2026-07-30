import 'package:mikozi_mobile/features/auth/domain/auth_session.dart';
import 'package:mikozi_mobile/features/auth/domain/otp_challenge.dart';

abstract interface class AuthRepository {
  Future<AuthSession?> restore();

  Future<OtpChallenge> requestOtp(String phoneNumber);

  Future<AuthSession> verifyOtp({
    required String challengeId,
    required String code,
  });

  Future<AuthSession> updateDisplayName({
    required AuthSession session,
    required String displayName,
  });

  Future<void> clearSession();
}
