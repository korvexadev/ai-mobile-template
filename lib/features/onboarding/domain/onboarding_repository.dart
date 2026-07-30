import 'package:mikozi_mobile/features/onboarding/domain/onboarding_status.dart';

abstract interface class OnboardingRepository {
  Future<OnboardingStatus> readStatus();

  Future<void> markCompleted();
}
