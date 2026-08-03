enum PaymentMethod { mobileMoney, bankTransfer }

enum PaymentStatus { pending, succeeded, failed, refunded }

class PaymentPlan {
  const PaymentPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.priceMinor,
    required this.currency,
    required this.billingPeriod,
    required this.dailyArticleLimit,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final int priceMinor;
  final String currency;
  final String billingPeriod;
  final int? dailyArticleLimit;

  bool get isUnlimited => dailyArticleLimit == null;
}

class MobileMoneyOperator {
  const MobileMoneyOperator({required this.id, required this.name});

  final String id;
  final String name;
}

class BankPaymentAccount {
  const BankPaymentAccount({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.expiresAt,
  });

  final String bankName;
  final String accountName;
  final String accountNumber;
  final DateTime expiresAt;
}

class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.plan,
    required this.method,
    required this.status,
    required this.amountMinor,
    required this.currency,
    required this.bankAccount,
    required this.createdAt,
    required this.completedAt,
  });

  final String id;
  final PaymentTransactionPlan plan;
  final PaymentMethod method;
  final PaymentStatus status;
  final int amountMinor;
  final String currency;
  final BankPaymentAccount? bankAccount;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isPending => status == PaymentStatus.pending;
}

class PaymentTransactionPlan {
  const PaymentTransactionPlan({
    required this.id,
    required this.code,
    required this.name,
  });

  final String id;
  final String code;
  final String name;
}
