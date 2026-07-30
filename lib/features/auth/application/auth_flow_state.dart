import 'package:mikozi_mobile/features/auth/domain/auth_failure.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_session.dart';
import 'package:mikozi_mobile/features/auth/domain/otp_challenge.dart';
import 'package:mikozi_mobile/features/auth/domain/phone_number.dart';

enum AuthStage {
  signedOut,
  requestingOtp,
  awaitingOtp,
  verifyingOtp,
  completingProfile,
  savingProfile,
  authenticated,
}

class AuthFlowState {
  const AuthFlowState({
    required this.stage,
    this.challenge,
    this.session,
    this.failure,
  });

  const AuthFlowState.signedOut() : this(stage: AuthStage.signedOut);

  final AuthStage stage;
  final OtpChallenge? challenge;
  final AuthSession? session;
  final AuthFailure? failure;

  bool get isBusy {
    return stage == AuthStage.requestingOtp ||
        stage == AuthStage.verifyingOtp ||
        stage == AuthStage.savingProfile;
  }

  String? get phoneNumberLabel {
    final phoneNumber = challenge?.phoneNumber;
    if (phoneNumber == null) {
      return null;
    }
    return MalawiPhoneNumber.parse(phoneNumber).display;
  }

  AuthFlowState copyWith({
    AuthStage? stage,
    OtpChallenge? challenge,
    AuthSession? session,
    AuthFailure? failure,
    bool clearFailure = false,
  }) {
    return AuthFlowState(
      stage: stage ?? this.stage,
      challenge: challenge ?? this.challenge,
      session: session ?? this.session,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
