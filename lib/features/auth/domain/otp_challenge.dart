class OtpChallenge {
  const OtpChallenge({
    required this.id,
    required this.phoneNumber,
    required this.expiresAt,
    required this.resendAfterSeconds,
  });

  final String id;
  final String phoneNumber;
  final DateTime expiresAt;
  final int resendAfterSeconds;
}
