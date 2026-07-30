import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_profile.dart';
import 'package:mikozi_mobile/features/profile/presentation/profile_page.dart';

void main() {
  testWidgets('renders the reader identity and functional settings groups', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    var openedSaved = false;
    var signedOut = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileContent(
          profile: const AuthProfile(
            id: 'reader-1',
            phoneNumber: '+265991234567',
            displayName: 'Mikozi Reader',
            preferredLanguage: 'en',
          ),
          savedCount: 3,
          signingOut: false,
          onOpenSaved: () => openedSaved = true,
          onSignOut: () => signedOut = true,
        ),
      ),
    );

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Mikozi Reader'), findsOneWidget);
    expect(find.text('+265991234567'), findsOneWidget);
    expect(find.text('Saved stories'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile-saved-stories')));
    await tester.tap(find.byKey(const ValueKey('profile-sign-out')));
    expect(openedSaved, isTrue);
    expect(signedOut, isTrue);
    expect(tester.takeException(), isNull);
  });
}
