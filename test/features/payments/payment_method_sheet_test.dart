import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/auth/application/auth_controller.dart';
import 'package:mikozi_mobile/features/payments/application/payments_controller.dart';
import 'package:mikozi_mobile/features/payments/domain/payment.dart';
import 'package:mikozi_mobile/features/payments/domain/payment_repository.dart';
import 'package:mikozi_mobile/features/payments/presentation/payment_pages.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  testWidgets('uses registered Airtel number and reveals TNM alternate entry', (
    tester,
  ) async {
    await tester.pumpWidget(_fixture());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open payment'));
    await tester.pumpAndSettle();

    expect(find.text('Airtel Money'), findsOneWidget);
    expect(find.text('+265 99 123 4567'), findsOneWidget);
    expect(find.text('Bank transfer'), findsOneWidget);
    expect(find.text('Use another number'), findsOneWidget);
    expect(find.byKey(const ValueKey('payment-phone-field')), findsNothing);

    await tester.tap(find.text('Use another number'));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('payment-phone-field')),
      '0881234567',
    );
    await tester.pump();

    expect(find.text('Pay with TNM Mpamba'), findsOneWidget);
  });

  testWidgets('copies readable bank details and confirms the action', (
    tester,
  ) async {
    await tester.pumpWidget(_fixture());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bank transfer'));
    await tester.pumpAndSettle();

    expect(find.text('1234567890'), findsOneWidget);
    final value = tester.widget<SelectableText>(
      find.widgetWithText(SelectableText, '1234567890'),
    );
    expect(value.style?.fontSize, greaterThanOrEqualTo(20));

    final copyButton = find.byKey(const ValueKey('copy-Account number'));
    await tester.ensureVisible(copyButton);
    await tester.tap(copyButton);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Account number copied'), findsOneWidget);
  });

  testWidgets('uses the adaptive phone input on iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(_fixture());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open payment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Use another number'));
      await tester.pump();

      expect(find.byType(CupertinoTextField), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Widget _fixture() {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(restoredSession: session(displayName: 'Reader')),
      ),
      paymentRepositoryProvider.overrideWithValue(const _PaymentRepository()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, child) {
            final auth = ref.watch(authControllerProvider);
            return TextButton(
              onPressed: auth.hasValue
                  ? () => showPaymentMethods(context, ref, _plan)
                  : null,
              child: const Text('Open payment'),
            );
          },
        ),
      ),
    ),
  );
}

const _plan = PaymentPlan(
  id: 'plan-id',
  code: 'plus',
  name: 'Mikozi Plus',
  description: null,
  priceMinor: 500000,
  currency: 'MWK',
  billingPeriod: 'monthly',
  dailyArticleLimit: null,
);

class _PaymentRepository implements PaymentRepository {
  const _PaymentRepository();

  @override
  Future<List<PaymentPlan>> listPlans() async => const [_plan];

  @override
  Future<List<MobileMoneyOperator>> listOperators() async => const [
    MobileMoneyOperator(id: 'airtel', name: 'Airtel Money'),
    MobileMoneyOperator(id: 'tnm', name: 'TNM Mpamba'),
  ];

  @override
  Future<List<PaymentTransaction>> listTransactions() async => const [];

  @override
  Future<PaymentTransaction?> pendingTransaction() async => null;

  @override
  Future<PaymentTransaction> initiateMobileMoney({
    required String planId,
    required String operatorId,
    required String phoneNumber,
    required String idempotencyKey,
  }) async => _transaction(bankAccount: null);

  @override
  Future<PaymentTransaction> initiateBankTransfer({
    required String planId,
    required String idempotencyKey,
  }) async {
    return _transaction(
      bankAccount: BankPaymentAccount(
        bankName: 'National Bank',
        accountName: 'Mikozi Limited',
        accountNumber: '1234567890',
        expiresAt: DateTime.utc(2030, 1, 2),
      ),
    );
  }

  @override
  Future<PaymentTransaction> verify(String transactionId) async {
    return _transaction(bankAccount: null);
  }
}

PaymentTransaction _transaction({required BankPaymentAccount? bankAccount}) {
  return PaymentTransaction(
    id: 'transaction-id',
    plan: const PaymentTransactionPlan(
      id: 'plan-id',
      code: 'plus',
      name: 'Mikozi Plus',
    ),
    method: bankAccount == null
        ? PaymentMethod.mobileMoney
        : PaymentMethod.bankTransfer,
    status: PaymentStatus.succeeded,
    amountMinor: 500000,
    currency: 'MWK',
    bankAccount: bankAccount,
    createdAt: DateTime.utc(2030),
    completedAt: DateTime.utc(2030),
  );
}
