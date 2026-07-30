import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/profile/application/reader_entitlement_provider.dart';
import 'package:mikozi_mobile/features/profile/domain/reader_entitlement.dart';
import 'package:mikozi_mobile/features/profile/domain/reader_entitlement_repository.dart';
import 'package:mikozi_mobile/features/profile/presentation/profile_settings_pages.dart';

void main() {
  testWidgets('subscription page renders the server entitlement', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readerEntitlementRepositoryProvider.overrideWithValue(
            const _EntitlementRepository(),
          ),
        ],
        child: const MaterialApp(home: SubscriptionPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reader Plus'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('privacy page renders concise reader data controls', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyPage()));

    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Your account'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Saved stories'), findsOneWidget);
    expect(find.text('Account controls'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _EntitlementRepository implements ReaderEntitlementRepository {
  const _EntitlementRepository();

  @override
  Future<ReaderEntitlement> fetch() async {
    return ReaderEntitlement(
      planName: 'Reader Plus',
      dailyArticleLimit: 10,
      articlesReadToday: 4,
      articlesRemainingToday: 6,
      resetsAt: DateTime.utc(2030, 1, 2),
      endsAt: null,
    );
  }
}
