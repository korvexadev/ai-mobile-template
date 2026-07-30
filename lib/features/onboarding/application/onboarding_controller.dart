import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/preferences_onboarding_repository.dart';
import '../domain/onboarding_repository.dart';
import '../domain/onboarding_status.dart';

part 'onboarding_controller.g.dart';

@Riverpod(keepAlive: true)
SharedPreferencesAsync sharedPreferences(Ref ref) {
  return SharedPreferencesAsync();
}

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) {
  return PreferencesOnboardingRepository(ref.watch(sharedPreferencesProvider));
}

@Riverpod(keepAlive: true)
Duration minimumSplashDuration(Ref ref) {
  return const Duration(milliseconds: 950);
}

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  Future<OnboardingStatus> build() async {
    final repository = ref.watch(onboardingRepositoryProvider);
    final status = repository.readStatus();
    await Future<void>.delayed(ref.watch(minimumSplashDurationProvider));
    return status;
  }

  Future<void> complete() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(onboardingRepositoryProvider).markCompleted();
      return OnboardingStatus.completed;
    });
  }
}
