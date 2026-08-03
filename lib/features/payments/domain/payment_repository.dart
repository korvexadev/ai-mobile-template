import 'payment.dart';

abstract interface class PaymentRepository {
  Future<List<PaymentPlan>> listPlans();

  Future<List<MobileMoneyOperator>> listOperators();

  Future<List<PaymentTransaction>> listTransactions();

  Future<PaymentTransaction?> pendingTransaction();

  Future<PaymentTransaction> initiateMobileMoney({
    required String planId,
    required String operatorId,
    required String phoneNumber,
    required String idempotencyKey,
  });

  Future<PaymentTransaction> initiateBankTransfer({
    required String planId,
    required String idempotencyKey,
  });

  Future<PaymentTransaction> verify(String transactionId);
}

class PaymentFailure implements Exception {
  const PaymentFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => message;
}
