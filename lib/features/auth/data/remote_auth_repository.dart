import 'package:mikozi_mobile/features/auth/data/auth_api.dart';
import 'package:mikozi_mobile/features/auth/data/auth_response_mapper.dart';
import 'package:mikozi_mobile/features/auth/data/auth_session_store.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_failure.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_repository.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_session.dart';
import 'package:mikozi_mobile/features/auth/domain/otp_challenge.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(
    this._api,
    this._sessionStore, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AuthApi _api;
  final AuthSessionStore _sessionStore;
  final DateTime Function() _clock;

  @override
  Future<AuthSession?> restore() async {
    final session = await _sessionStore.read();
    if (session == null) {
      return null;
    }
    final now = _clock().toUtc();
    if (session.tokens.accessIsValidAt(now)) {
      return session;
    }
    if (!session.tokens.refreshIsValidAt(now)) {
      await _sessionStore.delete();
      return null;
    }
    try {
      final json = await _api.refresh(session.tokens.refreshToken);
      final refreshed = session.copyWith(
        tokens: AuthResponseMapper.tokens(json),
      );
      await _sessionStore.write(refreshed);
      return refreshed;
    } on AuthFailure {
      await _sessionStore.delete();
      return null;
    }
  }

  @override
  Future<OtpChallenge> requestOtp(String phoneNumber) async {
    final json = await _api.requestOtp(phoneNumber);
    return AuthResponseMapper.challenge(json, phoneNumber: phoneNumber);
  }

  @override
  Future<AuthSession> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    final json = await _api.verifyOtp(challengeId: challengeId, code: code);
    final session = AuthResponseMapper.session(json);
    await _sessionStore.write(session);
    return session;
  }

  @override
  Future<AuthSession> updateDisplayName({
    required AuthSession session,
    required String displayName,
  }) async {
    final json = await _api.updateDisplayName(
      accessToken: session.tokens.accessToken,
      displayName: displayName,
    );
    final updated = session.copyWith(profile: AuthResponseMapper.profile(json));
    await _sessionStore.write(updated);
    return updated;
  }

  @override
  Future<void> clearSession() => _sessionStore.delete();
}
