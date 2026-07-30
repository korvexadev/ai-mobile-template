import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/auth/application/auth_controller.dart';
import 'package:mikozi_mobile/features/auth/domain/otp_challenge.dart';
import 'package:mikozi_mobile/features/home/application/homepage_provider.dart';
import 'package:mikozi_mobile/features/home/domain/homepage.dart';
import 'package:mikozi_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:mikozi_mobile/features/onboarding/domain/onboarding_repository.dart';
import 'package:mikozi_mobile/features/onboarding/domain/onboarding_status.dart';
import 'package:mikozi_mobile/main.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  testWidgets('new reader completes phone, OTP, and name flow', (tester) async {
    final authRepository = FakeAuthRepository();
    await tester.pumpWidget(_app(authRepository: authRepository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('phone-field')),
      '0991234567',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(authRepository.requestedPhoneNumber, '265991234567');
    expect(find.text('Check your\nmessages.'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('otp-field')), '123456');
    await tester.pumpAndSettle();

    expect(authRepository.verifiedCode, '123456');
    expect(find.text('What should\nwe call you?'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('name-field')),
      '  Chikondi  ',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(authRepository.savedName, 'Chikondi');
    expect(find.text('National'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Latest'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('returning reader opens the reader shell', (tester) async {
    final authRepository = FakeAuthRepository(
      restoredSession: session(displayName: 'Thoko'),
    );
    await tester.pumpWidget(_app(authRepository: authRepository));
    await tester.pumpAndSettle();

    expect(find.text('National'), findsOneWidget);
    expect(find.text('Your news,\nyour number.'), findsNothing);

    await tester.tap(find.text('Latest'));
    await tester.pumpAndSettle();

    expect(find.text('No latest stories yet.'), findsOneWidget);
  });

  testWidgets('phone entry fits a narrow scaled viewport', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app(authRepository: FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('phone-field')), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('requesting an OTP shows progress and completes', (tester) async {
    final completer = Completer<OtpChallenge>();
    final repository = FakeAuthRepository(requestOtpCompleter: completer);
    await tester.pumpWidget(_app(authRepository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('phone-field')),
      '0991234567',
    );
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Sending code'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('primary-action-progress')),
      findsOneWidget,
    );

    completer.complete(
      OtpChallenge(
        id: '8f64f28e-e913-4f4c-8530-a2e7f8ee9652',
        phoneNumber: '265991234567',
        expiresAt: DateTime.utc(2030),
        resendAfterSeconds: 60,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Check your\nmessages.'), findsOneWidget);
    expect(find.byKey(const ValueKey('primary-action-progress')), findsNothing);
  });

  testWidgets('unexpected OTP failure restores the Login action', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      requestOtpError: StateError('unexpected transport failure'),
    );
    await tester.pumpWidget(_app(authRepository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('phone-field')),
      '0991234567',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsOneWidget);
    expect(find.byKey(const ValueKey('primary-action-progress')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone entry uses the Material input on Android', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await tester.pumpWidget(_app(authRepository: FakeAuthRepository()));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('phone-field')), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('phone entry uses the Cupertino input on iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(_app(authRepository: FakeAuthRepository()));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('phone-field')), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Widget _app({required FakeAuthRepository authRepository}) {
  return ProviderScope(
    overrides: [
      onboardingRepositoryProvider.overrideWithValue(
        const _CompletedOnboardingRepository(),
      ),
      minimumSplashDurationProvider.overrideWithValue(Duration.zero),
      authRepositoryProvider.overrideWithValue(authRepository),
      homepageRepositoryProvider.overrideWithValue(
        const _StaticHomepageRepository(),
      ),
    ],
    child: const MikoziApp(),
  );
}

class _StaticHomepageRepository implements HomepageRepository {
  const _StaticHomepageRepository();

  @override
  Future<Homepage> fetch() async {
    return const Homepage(
      version: 1,
      topNavigation: [
        HomeTab(
          id: 'national',
          name: 'National',
          slug: 'national',
          sections: [],
        ),
      ],
      moreNavigation: [],
    );
  }
}

class _CompletedOnboardingRepository implements OnboardingRepository {
  const _CompletedOnboardingRepository();

  @override
  Future<void> markCompleted() async {}

  @override
  Future<OnboardingStatus> readStatus() async {
    return OnboardingStatus.completed;
  }
}
