import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/app/adaptive/mikozi_page_boundary.dart';
import 'package:mikozi_mobile/features/payments/application/payments_controller.dart';
import 'package:mikozi_mobile/features/payments/domain/payment.dart';
import 'package:mikozi_mobile/features/payments/domain/payment_repository.dart';
import 'package:mikozi_mobile/features/payments/presentation/payment_pages.dart';
import 'package:mikozi_mobile/features/profile/application/reader_entitlement_provider.dart';
import 'package:mikozi_mobile/features/profile/domain/reader_entitlement.dart';
import 'package:mikozi_mobile/features/profile/domain/reader_entitlement_repository.dart';
import 'package:mikozi_mobile/features/profile/presentation/profile_settings_pages.dart';
import 'package:mikozi_mobile/main.dart';

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
          paymentRepositoryProvider.overrideWithValue(
            const _PaymentRepository(),
          ),
        ],
        child: const MaterialApp(home: SubscriptionPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reader Plus'), findsOneWidget);
    expect(find.text('Choose plan'), findsOneWidget);
    expect(find.text('Mikozi Plus'), findsOneWidget);
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

  testWidgets('notifications explain the current delivery status', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: NotificationSettingsPage()),
    );

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.textContaining('not available yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('subscription controls render under the Cupertino app host', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readerEntitlementRepositoryProvider.overrideWithValue(
            const _EntitlementRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(
            const _PaymentRepository(),
          ),
        ],
        child: const CupertinoApp(
          localizationsDelegates: mikoziLocalizationsDelegates,
          supportedLocales: [Locale('en', 'US')],
          home: MikoziPageBoundary(child: SubscriptionPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mikozi Plus'), findsOneWidget);
    expect(find.text('Choose plan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PaymentRepository implements PaymentRepository {
  const _PaymentRepository();

  @override
  Future<List<PaymentPlan>> listPlans() async => const [
    PaymentPlan(
      id: 'plan-id',
      code: 'plus',
      name: 'Mikozi Plus',
      description: null,
      priceMinor: 500000,
      currency: 'MWK',
      billingPeriod: 'monthly',
      dailyArticleLimit: null,
    ),
  ];

  @override
  Future<List<MobileMoneyOperator>> listOperators() async => const [];

  @override
  Future<List<PaymentTransaction>> listTransactions() async => const [];

  @override
  Future<PaymentTransaction?> pendingTransaction() async => null;

  @override
  Future<PaymentTransaction> initiateBankTransfer({
    required String planId,
    required String idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<PaymentTransaction> initiateMobileMoney({
    required String planId,
    required String operatorId,
    required String phoneNumber,
    required String idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<PaymentTransaction> verify(String transactionId) =>
      throw UnimplementedError();
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
