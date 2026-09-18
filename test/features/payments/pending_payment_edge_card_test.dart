import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/app/adaptive/mikozi_page_boundary.dart';
import 'package:mikozi_mobile/features/payments/application/payments_controller.dart';
import 'package:mikozi_mobile/features/payments/domain/payment.dart';
import 'package:mikozi_mobile/features/payments/domain/payment_repository.dart';
import 'package:mikozi_mobile/features/payments/presentation/widgets/pending_payment_edge_card.dart';
import 'package:mikozi_mobile/features/profile/application/reader_entitlement_provider.dart';
import 'package:mikozi_mobile/features/profile/domain/reader_entitlement.dart';
import 'package:mikozi_mobile/features/profile/domain/reader_entitlement_repository.dart';
import 'package:mikozi_mobile/main.dart';

void main() {
  testWidgets('shows completion feedback without a ScaffoldMessenger', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(
            const _PaymentRepository(),
          ),
          readerEntitlementRepositoryProvider.overrideWithValue(
            const _EntitlementRepository(),
          ),
        ],
        child: const CupertinoApp(
          localizationsDelegates: mikoziLocalizationsDelegates,
          supportedLocales: [Locale('en', 'US')],
          home: MikoziPageBoundary(child: _PaymentHarness()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('verify-payment')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey('payment-completion-feedback')),
      findsOneWidget,
    );
    expect(
      find.text('Payment confirmed. Your plan is active.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

class _PaymentHarness extends ConsumerWidget {
  const _PaymentHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsControllerProvider);
    final entitlement = ref.watch(readerEntitlementProvider);
    if (!payments.hasValue || !entitlement.hasValue) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        const PendingPaymentEdgeCard(),
        CupertinoButton(
          key: const ValueKey('verify-payment'),
          onPressed: ref
              .read(paymentsControllerProvider.notifier)
              .verifyPending,
          child: const Text('Verify'),
        ),
      ],
    );
  }
}

class _PaymentRepository implements PaymentRepository {
  const _PaymentRepository();

  @override
  Future<List<PaymentPlan>> listPlans() async => const [];

  @override
  Future<List<MobileMoneyOperator>> listOperators() async => const [];

  @override
  Future<List<PaymentTransaction>> listTransactions() async => [_pending];

  @override
  Future<PaymentTransaction?> pendingTransaction() async => _pending;

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
  Future<PaymentTransaction> verify(String transactionId) async {
    return _transaction(PaymentStatus.succeeded);
  }
}

class _EntitlementRepository implements ReaderEntitlementRepository {
  const _EntitlementRepository();

  @override
  Future<ReaderEntitlement> fetch() async {
    return ReaderEntitlement(
      planName: 'Free',
      dailyArticleLimit: 3,
      articlesReadToday: 0,
      articlesRemainingToday: 3,
      resetsAt: DateTime.utc(2030),
      endsAt: null,
    );
  }
}

final _pending = _transaction(PaymentStatus.pending);

PaymentTransaction _transaction(PaymentStatus status) {
  return PaymentTransaction(
    id: 'transaction-id',
    plan: const PaymentTransactionPlan(
      id: 'plan-id',
      code: 'plus',
      name: 'Mikozi Plus',
    ),
    method: PaymentMethod.mobileMoney,
    status: status,
    amountMinor: 500000,
    currency: 'MWK',
    bankAccount: null,
    createdAt: DateTime.utc(2030),
    completedAt: status == PaymentStatus.succeeded
        ? DateTime.utc(2030, 1, 2)
        : null,
  );
}
