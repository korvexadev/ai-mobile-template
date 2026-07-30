import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/networking/network_providers.dart';
import '../data/auth_api.dart';
import '../data/auth_session_store.dart';
import '../data/remote_auth_repository.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import '../domain/phone_number.dart';
import 'auth_flow_state.dart';

part 'auth_controller.g.dart';

const _unexpectedAuthFailure = AuthFailure(
  code: 'AUTH_UNAVAILABLE',
  message: 'Something went wrong. Please try again.',
);

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

@Riverpod(keepAlive: true)
AuthSessionStore authSessionStore(Ref ref) {
  return SecureAuthSessionStore(ref.watch(secureStorageProvider));
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return RemoteAuthRepository(
    AuthApi(ref.watch(dioProvider)),
    ref.watch(authSessionStoreProvider),
  );
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AuthFlowState> build() async {
    final session = await ref.watch(authRepositoryProvider).restore();
    if (session == null) {
      return const AuthFlowState.signedOut();
    }
    return AuthFlowState(
      stage: session.needsName
          ? AuthStage.completingProfile
          : AuthStage.authenticated,
      session: session,
    );
  }

  Future<void> requestOtp(String input) async {
    final phoneNumber = _phoneNumber(input);
    if (phoneNumber == null) {
      return;
    }
    state = AsyncData(
      _current.copyWith(stage: AuthStage.requestingOtp, clearFailure: true),
    );
    try {
      final challenge = await ref
          .read(authRepositoryProvider)
          .requestOtp(phoneNumber.value);
      state = AsyncData(
        AuthFlowState(stage: AuthStage.awaitingOtp, challenge: challenge),
      );
    } on AuthFailure catch (failure) {
      state = AsyncData(
        AuthFlowState(stage: AuthStage.signedOut, failure: failure),
      );
    } on Object {
      state = const AsyncData(
        AuthFlowState(
          stage: AuthStage.signedOut,
          failure: _unexpectedAuthFailure,
        ),
      );
    }
  }

  Future<void> verifyOtp(String code) async {
    final challenge = _current.challenge;
    if (challenge == null || !RegExp(r'^\d{6}$').hasMatch(code)) {
      state = AsyncData(
        _current.copyWith(
          failure: const AuthFailure(
            code: 'INVALID_OTP',
            message: 'Enter the six-digit code.',
          ),
        ),
      );
      return;
    }
    state = AsyncData(
      _current.copyWith(stage: AuthStage.verifyingOtp, clearFailure: true),
    );
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .verifyOtp(challengeId: challenge.id, code: code);
      state = AsyncData(
        AuthFlowState(
          stage: session.needsName
              ? AuthStage.completingProfile
              : AuthStage.authenticated,
          session: session,
        ),
      );
    } on AuthFailure catch (failure) {
      state = AsyncData(
        AuthFlowState(
          stage: AuthStage.awaitingOtp,
          challenge: challenge,
          failure: failure,
        ),
      );
    } on Object {
      state = AsyncData(
        AuthFlowState(
          stage: AuthStage.awaitingOtp,
          challenge: challenge,
          failure: _unexpectedAuthFailure,
        ),
      );
    }
  }

  Future<void> completeProfile(String input) async {
    final name = input.trim();
    final session = _current.session;
    if (session == null) {
      return;
    }
    if (name.isEmpty || name.length > 80) {
      state = AsyncData(
        _current.copyWith(
          failure: const AuthFailure(
            code: 'INVALID_DISPLAY_NAME',
            message: 'Enter your name.',
          ),
        ),
      );
      return;
    }
    state = AsyncData(
      _current.copyWith(stage: AuthStage.savingProfile, clearFailure: true),
    );
    try {
      final updated = await ref
          .read(authRepositoryProvider)
          .updateDisplayName(session: session, displayName: name);
      state = AsyncData(
        AuthFlowState(stage: AuthStage.authenticated, session: updated),
      );
    } on AuthFailure catch (failure) {
      state = AsyncData(
        AuthFlowState(
          stage: AuthStage.completingProfile,
          session: session,
          failure: failure,
        ),
      );
    } on Object {
      state = AsyncData(
        AuthFlowState(
          stage: AuthStage.completingProfile,
          session: session,
          failure: _unexpectedAuthFailure,
        ),
      );
    }
  }

  void useDifferentNumber() {
    state = const AsyncData(AuthFlowState.signedOut());
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).clearSession();
    state = const AsyncData(AuthFlowState.signedOut());
  }

  Future<AuthSession?> validSession() async {
    final session = _current.session;
    final now = DateTime.now().toUtc();
    if (session != null && session.tokens.accessIsValidAt(now)) {
      return session;
    }

    final restored = await ref.read(authRepositoryProvider).restore();
    if (restored == null) {
      state = const AsyncData(AuthFlowState.signedOut());
      return null;
    }
    state = AsyncData(
      AuthFlowState(
        stage: restored.needsName
            ? AuthStage.completingProfile
            : AuthStage.authenticated,
        session: restored,
      ),
    );
    return restored;
  }

  MalawiPhoneNumber? _phoneNumber(String input) {
    try {
      return MalawiPhoneNumber.parse(input);
    } on AuthFailure catch (failure) {
      state = AsyncData(
        AuthFlowState(stage: AuthStage.signedOut, failure: failure),
      );
      return null;
    }
  }

  AuthFlowState get _current {
    return state.value ?? const AuthFlowState.signedOut();
  }
}
