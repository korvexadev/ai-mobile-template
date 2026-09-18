import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/auth/domain/auth_profile.dart';
import 'package:mikozi_mobile/features/profile/domain/reader_entitlement.dart';
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
    var openedSubscription = false;
    var deletedAccount = false;

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
          entitlement: ReaderEntitlement(
            planName: 'Reader Plus',
            dailyArticleLimit: 10,
            articlesReadToday: 4,
            articlesRemainingToday: 6,
            resetsAt: DateTime.utc(2030, 1, 2),
            endsAt: null,
          ),
          entitlementLoading: false,
          appVersion: '1.0.0 (1)',
          signingOut: false,
          onOpenSaved: () => openedSaved = true,
          onOpenNotifications: () {},
          onOpenSubscription: () => openedSubscription = true,
          onOpenTransactions: () {},
          onOpenPrivacy: () {},
          onOpenAbout: () {},
          onDeleteAccount: () => deletedAccount = true,
          onSignOut: () => signedOut = true,
        ),
      ),
    );

    expect(find.text('Profile'), findsNothing);
    expect(find.text('MR'), findsOneWidget);
    expect(find.text('Mikozi Reader'), findsOneWidget);
    expect(find.text('+265991234567'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('stories remaining today'), findsOneWidget);
    expect(find.text('4'), findsNothing);
    expect(find.text('stories read today'), findsNothing);
    expect(find.text('Reader Plus'), findsNWidgets(2));
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Subscription'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Saved stories'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile-daily-allowance')));
    expect(openedSubscription, isTrue);

    await tester.tap(find.byKey(const ValueKey('profile-saved-stories')));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('profile-delete-account')));
    await tester.tap(find.byKey(const ValueKey('profile-sign-out')));
    expect(openedSaved, isTrue);
    expect(deletedAccount, isTrue);
    expect(signedOut, isTrue);
    expect(find.text('Mikozi 1.0.0 (1)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides payment settings during a global free-reading window', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileContent(
          profile: const AuthProfile(
            id: 'reader-1',
            phoneNumber: '+265991234567',
            displayName: 'Mikozi Reader',
            preferredLanguage: 'en',
          ),
          savedCount: 0,
          entitlement: ReaderEntitlement(
            planName: 'Free',
            dailyArticleLimit: 3,
            articlesReadToday: 3,
            articlesRemainingToday: null,
            resetsAt: DateTime.utc(2030, 1, 2),
            endsAt: null,
            globalFreeAccess: true,
            paymentsEnabled: false,
          ),
          entitlementLoading: false,
          appVersion: '1.0.0 (1)',
          signingOut: false,
          onOpenSaved: () {},
          onOpenNotifications: () {},
          onOpenSubscription: () {},
          onOpenTransactions: () {},
          onOpenPrivacy: () {},
          onOpenAbout: () {},
          onDeleteAccount: () {},
          onSignOut: () {},
        ),
      ),
    );

    expect(find.text('Free'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('stories read today'), findsOneWidget);
    expect(find.text('stories remaining today'), findsNothing);
    expect(find.text('Subscription'), findsNothing);
    expect(find.text('Transactions'), findsNothing);
  });
}
