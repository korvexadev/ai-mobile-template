import 'package:dio/dio.dart';

import '../../../core/networking/mikozi_api_client.dart';
import '../domain/payment.dart';
import '../domain/payment_repository.dart';

class RemotePaymentRepository implements PaymentRepository {
  RemotePaymentRepository(this._api, this._accessToken);

  final MikoziApiClient _api;
  final Future<String?> Function() _accessToken;

  @override
  Future<List<PaymentPlan>> listPlans() async {
    return _guard(() async {
      final data = await _api.getPaymentPlans(accessToken: await _token());
      return data.map(_plan).toList(growable: false);
    });
  }

  @override
  Future<List<MobileMoneyOperator>> listOperators() async {
    return _guard(() async {
      final data = await _api.getMobileMoneyOperators(
        accessToken: await _token(),
      );
      return data
          .map(
            (item) => MobileMoneyOperator(
              id: item['id'] as String,
              name: item['name'] as String,
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Future<List<PaymentTransaction>> listTransactions() async {
    return _guard(() async {
      final data = await _api.getPaymentTransactions(
        accessToken: await _token(),
      );
      return data.map(_transaction).toList(growable: false);
    });
  }

  @override
  Future<PaymentTransaction?> pendingTransaction() async {
    return _guard(() async {
      final data = await _api.getPendingPayment(accessToken: await _token());
      return data == null ? null : _transaction(data);
    });
  }

  @override
  Future<PaymentTransaction> initiateMobileMoney({
    required String planId,
    required String operatorId,
    required String phoneNumber,
    required String idempotencyKey,
  }) {
    return _guard(() async {
      return _transaction(
        await _api.initiateMobileMoneyPayment(
          accessToken: await _token(),
          planId: planId,
          operatorId: operatorId,
          phoneNumber: phoneNumber,
          idempotencyKey: idempotencyKey,
        ),
      );
    });
  }

  @override
  Future<PaymentTransaction> initiateBankTransfer({
    required String planId,
    required String idempotencyKey,
  }) {
    return _guard(() async {
      return _transaction(
        await _api.initiateBankTransferPayment(
          accessToken: await _token(),
          planId: planId,
          idempotencyKey: idempotencyKey,
        ),
      );
    });
  }

  @override
  Future<PaymentTransaction> verify(String transactionId) {
    return _guard(() async {
      return _transaction(
        await _api.verifyPayment(
          accessToken: await _token(),
          transactionId: transactionId,
        ),
      );
    });
  }

  Future<String> _token() async {
    final token = await _accessToken();
    if (token == null) {
      throw const PaymentFailure(
        code: 'AUTH_REQUIRED',
        message: 'Sign in to manage payments.',
      );
    }
    return token;
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PaymentFailure {
      rethrow;
    } on DioException catch (error) {
      throw _failure(error);
    } on FormatException {
      throw const PaymentFailure(
        code: 'INVALID_RESPONSE',
        message: 'Mikozi returned an unexpected payment response.',
      );
    } on TypeError {
      throw const PaymentFailure(
        code: 'INVALID_RESPONSE',
        message: 'Mikozi returned an unexpected payment response.',
      );
    }
  }

  PaymentPlan _plan(Map<String, dynamic> json) {
    return PaymentPlan(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceMinor: json['priceMinor'] as int,
      currency: json['currency'] as String,
      billingPeriod: json['billingPeriod'] as String,
      dailyArticleLimit: json['dailyArticleLimit'] as int?,
    );
  }

  PaymentTransaction _transaction(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>;
    final bank = json['bankAccount'] as Map<String, dynamic>?;
    return PaymentTransaction(
      id: json['id'] as String,
      plan: PaymentTransactionPlan(
        id: plan['id'] as String,
        code: plan['code'] as String,
        name: plan['name'] as String,
      ),
      method: switch (json['method']) {
        'bank_transfer' => PaymentMethod.bankTransfer,
        _ => PaymentMethod.mobileMoney,
      },
      status: switch (json['status']) {
        'succeeded' => PaymentStatus.succeeded,
        'failed' => PaymentStatus.failed,
        'refunded' => PaymentStatus.refunded,
        _ => PaymentStatus.pending,
      },
      amountMinor: json['amountMinor'] as int,
      currency: json['currency'] as String,
      bankAccount: bank == null
          ? null
          : BankPaymentAccount(
              bankName: bank['bankName'] as String,
              accountName: bank['accountName'] as String,
              accountNumber: bank['accountNumber'] as String,
              expiresAt: DateTime.parse(bank['expiresAt'] as String),
            ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: _date(json['completedAt']),
    );
  }

  DateTime? _date(Object? value) {
    return value is String ? DateTime.tryParse(value) : null;
  }

  PaymentFailure _failure(DioException exception) {
    final response = exception.response?.data;
    if (response is Map<String, dynamic>) {
      final error = response['error'];
      if (error is Map<String, dynamic>) {
        final code = error['code'];
        final message = error['message'];
        if (code is String && message is String) {
          return PaymentFailure(code: code, message: message);
        }
      }
    }
    return const PaymentFailure(
      code: 'PAYMENT_UNAVAILABLE',
      message: 'Payments are unavailable. Check your connection and try again.',
    );
  }
}
