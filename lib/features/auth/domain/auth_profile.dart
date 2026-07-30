class AuthProfile {
  const AuthProfile({
    required this.id,
    required this.phoneNumber,
    required this.displayName,
    required this.preferredLanguage,
  });

  final String id;
  final String phoneNumber;
  final String? displayName;
  final String preferredLanguage;

  bool get needsName => displayName == null || displayName!.trim().isEmpty;

  AuthProfile copyWith({String? displayName}) {
    return AuthProfile(
      id: id,
      phoneNumber: phoneNumber,
      displayName: displayName ?? this.displayName,
      preferredLanguage: preferredLanguage,
    );
  }
}
