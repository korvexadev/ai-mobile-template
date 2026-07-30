import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_repository.dart';
import '../domain/onboarding_status.dart';

final class PreferencesOnboardingRepository implements OnboardingRepository {
  PreferencesOnboardingRepository(this._preferences);

  static const _completedKey = 'onboarding.completed.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<OnboardingStatus> readStatus() async {
    final completed = await _preferences.getBool(_completedKey) ?? false;
    return completed ? OnboardingStatus.completed : OnboardingStatus.pending;
  }

  @override
  Future<void> markCompleted() {
    return _preferences.setBool(_completedKey, true);
  }
}
