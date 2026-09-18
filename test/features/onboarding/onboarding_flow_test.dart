import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/auth/application/auth_controller.dart';
import 'package:mikozi_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:mikozi_mobile/features/onboarding/domain/onboarding_repository.dart';
import 'package:mikozi_mobile/features/onboarding/domain/onboarding_status.dart';
import 'package:mikozi_mobile/main.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  testWidgets('first launch completes three onboarding pages', (tester) async {
    final repository = _FakeOnboardingRepository(
      initialStatus: OnboardingStatus.pending,
    );
    final authRepository = FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repository),
          minimumSplashDurationProvider.overrideWithValue(Duration.zero),
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
        child: const MikoziApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Access the latest and hottest news'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Made with entertainment at its core.'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Enjoy the latest'), findsOneWidget);
    await tester.tap(find.text('Start reading'));
    await tester.pumpAndSettle();

    expect(repository.completed, isTrue);
    expect(
      find.text('Sign in with your phone number to get started.'),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('returning launch opens Login after splash', (tester) async {
    final repository = _FakeOnboardingRepository(
      initialStatus: OnboardingStatus.completed,
    );
    final authRepository = FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repository),
          minimumSplashDurationProvider.overrideWithValue(Duration.zero),
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
        child: const MikoziApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Sign in with your phone number to get started.'),
      findsOneWidget,
    );
    expect(find.text('Access the latest and hottest news'), findsNothing);
  });
}

final class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({required this.initialStatus});

  final OnboardingStatus initialStatus;
  bool completed = false;

  @override
  Future<void> markCompleted() async {
    completed = true;
  }

  @override
  Future<OnboardingStatus> readStatus() async {
    return completed ? OnboardingStatus.completed : initialStatus;
  }
}
