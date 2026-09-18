import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/networking/mikozi_api_client.dart';
import '../../../core/networking/network_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_failure.dart';
import '../../auth/domain/phone_number.dart';
import '../../profile/application/reader_entitlement_provider.dart';
import '../data/remote_payment_repository.dart';
import '../domain/mobile_money_network.dart';
import '../domain/payment.dart';
import '../domain/payment_repository.dart';

part 'payments_controller.g.dart';

class PaymentsState {
  const PaymentsState({
    required this.plans,
    required this.operators,
    required this.transactions,
    required this.pending,
    this.processing = false,
    this.processingPlanId,
    this.failure,
  });

  final List<PaymentPlan> plans;
  final List<MobileMoneyOperator> operators;
  final List<PaymentTransaction> transactions;
  final PaymentTransaction? pending;
  final bool processing;
  final String? processingPlanId;
  final PaymentFailure? failure;

  PaymentsState copyWith({
    List<PaymentPlan>? plans,
    List<MobileMoneyOperator>? operators,
    List<PaymentTransaction>? transactions,
    PaymentTransaction? pending,
    bool clearPending = false,
    bool? processing,
    String? processingPlanId,
    bool clearProcessingPlan = false,
    PaymentFailure? failure,
    bool clearFailure = false,
  }) {
    return PaymentsState(
      plans: plans ?? this.plans,
      operators: operators ?? this.operators,
      transactions: transactions ?? this.transactions,
      pending: clearPending ? null : pending ?? this.pending,
      processing: processing ?? this.processing,
      processingPlanId: clearProcessingPlan
          ? null
          : processingPlanId ?? this.processingPlanId,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) {
  return RemotePaymentRepository(
    MikoziApiClient(ref.watch(dioProvider)),
    () async {
      final session = await ref
          .read(authControllerProvider.notifier)
          .validSession();
      return session?.tokens.accessToken;
    },
  );
}

@Riverpod(keepAlive: true)
class PaymentsController extends _$PaymentsController {
  Timer? _poller;

  @override
  Future<PaymentsState> build() async {
    ref.onDispose(_stopPolling);
    final repository = ref.watch(paymentRepositoryProvider);
    final results = await Future.wait<Object?>([
      repository.listPlans(),
      repository.listOperators(),
      repository.listTransactions(),
      repository.pendingTransaction(),
    ]);
    final snapshot = PaymentsState(
      plans: results[0] as List<PaymentPlan>,
      operators: results[1] as List<MobileMoneyOperator>,
      transactions: results[2] as List<PaymentTransaction>,
      pending: results[3] as PaymentTransaction?,
    );
    _syncPolling(snapshot.pending);
    return snapshot;
  }

  Future<void> refresh() async {
    final repository = ref.read(paymentRepositoryProvider);
    final current = state.value;
    if (current == null || current.processing) return;
    try {
      final results = await Future.wait<Object?>([
        repository.listPlans(),
        repository.listOperators(),
        repository.listTransactions(),
        repository.pendingTransaction(),
      ]);
      final next = current.copyWith(
        plans: results[0] as List<PaymentPlan>,
        operators: results[1] as List<MobileMoneyOperator>,
        transactions: results[2] as List<PaymentTransaction>,
        pending: results[3] as PaymentTransaction?,
        clearPending: results[3] == null,
        clearFailure: true,
      );
      state = AsyncData(next);
      _syncPolling(next.pending);
    } on PaymentFailure catch (failure) {
      state = AsyncData(current.copyWith(failure: failure));
    }
  }

  Future<PaymentTransaction?> initiateMobileMoney({
    required PaymentPlan plan,
    required MobileMoneyOperator operator,
    required String phoneNumber,
  }) async {
    final current = state.value;
    if (current == null) return null;
    late final String normalizedPhoneNumber;
    try {
      normalizedPhoneNumber = MalawiPhoneNumber.parse(phoneNumber).value;
    } on AuthFailure catch (failure) {
      state = AsyncData(
        current.copyWith(
          failure: PaymentFailure(code: failure.code, message: failure.message),
        ),
      );
      return null;
    }
    final network = MobileMoneyNetwork.fromPhone(normalizedPhoneNumber);
    if (network == null || !network.supports(operator)) {
      state = AsyncData(
        current.copyWith(
          failure: const PaymentFailure(
            code: 'MOBILE_MONEY_NETWORK_MISMATCH',
            message: 'Use the mobile money option for this phone number.',
          ),
        ),
      );
      return null;
    }
    return _initiate(
      (repository) => repository.initiateMobileMoney(
        planId: plan.id,
        operatorId: operator.id,
        phoneNumber: normalizedPhoneNumber,
        idempotencyKey: _idempotencyKey(),
      ),
      planId: plan.id,
    );
  }

  void clearFailure() {
    final current = state.value;
    if (current == null || current.failure == null) return;
    state = AsyncData(current.copyWith(clearFailure: true));
  }

  Future<PaymentTransaction?> initiateBankTransfer(PaymentPlan plan) {
    return _initiate(
      (repository) => repository.initiateBankTransfer(
        planId: plan.id,
        idempotencyKey: _idempotencyKey(),
      ),
      planId: plan.id,
    );
  }

  Future<PaymentTransaction?> verifyPending() async {
    final current = state.value;
    final transaction = current?.pending;
    if (current == null || transaction == null || current.processing) {
      return transaction;
    }
    state = AsyncData(current.copyWith(processing: true, clearFailure: true));
    try {
      final verified = await ref
          .read(paymentRepositoryProvider)
          .verify(transaction.id);
      _applyTransaction(current, verified);
      return verified;
    } on PaymentFailure catch (failure) {
      state = AsyncData(current.copyWith(processing: false, failure: failure));
      return null;
    } on Object {
      state = AsyncData(
        current.copyWith(
          processing: false,
          failure: const PaymentFailure(
            code: 'PAYMENT_UNAVAILABLE',
            message: 'The payment status could not be checked. Try again.',
          ),
        ),
      );
      return null;
    }
  }

  Future<PaymentTransaction?> _initiate(
    Future<PaymentTransaction> Function(PaymentRepository repository) action, {
    required String planId,
  }) async {
    final current = state.value;
    if (current == null || current.processing || current.pending != null) {
      return current?.pending;
    }
    state = AsyncData(
      current.copyWith(
        processing: true,
        processingPlanId: planId,
        clearFailure: true,
      ),
    );
    try {
      final transaction = await action(ref.read(paymentRepositoryProvider));
      _applyTransaction(current, transaction);
      return transaction;
    } on PaymentFailure catch (failure) {
      state = AsyncData(
        current.copyWith(
          processing: false,
          clearProcessingPlan: true,
          failure: failure,
        ),
      );
      return null;
    } on Object {
      state = AsyncData(
        current.copyWith(
          processing: false,
          clearProcessingPlan: true,
          failure: const PaymentFailure(
            code: 'PAYMENT_UNAVAILABLE',
            message: 'The payment could not be started. Try again.',
          ),
        ),
      );
      return null;
    }
  }

  void _applyTransaction(
    PaymentsState current,
    PaymentTransaction transaction,
  ) {
    final transactions = current.transactions.toList()
      ..removeWhere((item) => item.id == transaction.id)
      ..insert(0, transaction);
    final next = current.copyWith(
      transactions: List.unmodifiable(transactions),
      pending: transaction.isPending ? transaction : null,
      clearPending: !transaction.isPending,
      processing: false,
      clearProcessingPlan: true,
      clearFailure: true,
    );
    state = AsyncData(next);
    _syncPolling(next.pending);
    if (transaction.status == PaymentStatus.succeeded) {
      ref.invalidate(readerEntitlementProvider);
    }
  }

  void _syncPolling(PaymentTransaction? transaction) {
    if (transaction == null) {
      _stopPolling();
      return;
    }
    _poller ??= Timer.periodic(const Duration(seconds: 12), (_) {
      unawaited(verifyPending());
    });
  }

  void _stopPolling() {
    _poller?.cancel();
    _poller = null;
  }
}

String _idempotencyKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
}
