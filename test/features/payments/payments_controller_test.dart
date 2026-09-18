import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/payments/application/payments_controller.dart';
import 'package:mikozi_mobile/features/payments/domain/payment.dart';
import 'package:mikozi_mobile/features/payments/domain/payment_repository.dart';

void main() {
  test('does not start a second charge while one is pending', () async {
    final repository = _PaymentRepository();
    final container = ProviderContainer(
      overrides: [paymentRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(paymentsControllerProvider.future);
    final controller = container.read(paymentsControllerProvider.notifier);

    final first = await controller.initiateMobileMoney(
      plan: _plan,
      operator: _operator,
      phoneNumber: '0991 234 567',
    );
    final second = await controller.initiateMobileMoney(
      plan: _plan,
      operator: _operator,
      phoneNumber: '0991 234 567',
    );

    expect(first?.id, _pending.id);
    expect(second?.id, _pending.id);
    expect(repository.initiations, 1);
    expect(repository.lastPhoneNumber, '265991234567');
    expect(
      container.read(paymentsControllerProvider).value?.pending?.id,
      _pending.id,
    );
  });

  test(
    'rejects an invalid payer phone before calling the repository',
    () async {
      final repository = _PaymentRepository();
      final container = ProviderContainer(
        overrides: [paymentRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      await container.read(paymentsControllerProvider.future);

      final transaction = await container
          .read(paymentsControllerProvider.notifier)
          .initiateMobileMoney(
            plan: _plan,
            operator: _operator,
            phoneNumber: '123',
          );

      expect(transaction, isNull);
      expect(repository.initiations, 0);
      expect(
        container.read(paymentsControllerProvider).value?.failure?.code,
        'INVALID_PHONE_NUMBER',
      );
    },
  );

  test('rejects an operator that does not match the payer prefix', () async {
    final repository = _PaymentRepository();
    final container = ProviderContainer(
      overrides: [paymentRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(paymentsControllerProvider.future);

    final transaction = await container
        .read(paymentsControllerProvider.notifier)
        .initiateMobileMoney(
          plan: _plan,
          operator: const MobileMoneyOperator(
            id: 'tnm-operator',
            name: 'TNM Mpamba',
          ),
          phoneNumber: '0991234567',
        );

    expect(transaction, isNull);
    expect(repository.initiations, 0);
    expect(
      container.read(paymentsControllerProvider).value?.failure?.code,
      'MOBILE_MONEY_NETWORK_MISMATCH',
    );
  });

  test(
    'unexpected verification failure exits progress and can retry',
    () async {
      final repository = _PaymentRepository()..failNextVerification = true;
      final container = ProviderContainer(
        overrides: [paymentRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      await container.read(paymentsControllerProvider.future);
      final controller = container.read(paymentsControllerProvider.notifier);
      await controller.initiateMobileMoney(
        plan: _plan,
        operator: _operator,
        phoneNumber: '0991 234 567',
      );

      expect(await controller.verifyPending(), isNull);
      final failed = container.read(paymentsControllerProvider).value!;
      expect(failed.processing, isFalse);
      expect(failed.failure?.code, 'PAYMENT_UNAVAILABLE');
      expect(failed.pending?.id, _pending.id);

      expect((await controller.verifyPending())?.id, _pending.id);
      expect(container.read(paymentsControllerProvider).value?.failure, isNull);
    },
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

const _operator = MobileMoneyOperator(id: 'operator-id', name: 'Airtel Money');

final _pending = PaymentTransaction(
  id: 'transaction-id',
  plan: const PaymentTransactionPlan(
    id: 'plan-id',
    code: 'plus',
    name: 'Mikozi Plus',
  ),
  method: PaymentMethod.mobileMoney,
  status: PaymentStatus.pending,
  amountMinor: 500000,
  currency: 'MWK',
  bankAccount: null,
  createdAt: DateTime.utc(2030),
  completedAt: null,
);

class _PaymentRepository implements PaymentRepository {
  int initiations = 0;
  String? lastPhoneNumber;
  bool failNextVerification = false;

  @override
  Future<List<PaymentPlan>> listPlans() async => const [_plan];

  @override
  Future<List<MobileMoneyOperator>> listOperators() async => const [_operator];

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
  }) async {
    initiations += 1;
    lastPhoneNumber = phoneNumber;
    expect(idempotencyKey, hasLength(32));
    return _pending;
  }

  @override
  Future<PaymentTransaction> initiateBankTransfer({
    required String planId,
    required String idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<PaymentTransaction> verify(String transactionId) async {
    if (failNextVerification) {
      failNextVerification = false;
      throw StateError('temporary failure');
    }
    return _pending;
  }
}
