import '../../auth/domain/auth_failure.dart';
import '../../auth/domain/phone_number.dart';
import 'payment.dart';

enum MobileMoneyNetwork {
  airtelMoney,
  tnmMpamba;

  static MobileMoneyNetwork? fromPhone(String input) {
    try {
      final phone = MalawiPhoneNumber.parse(input).value;
      return switch (phone[3]) {
        '9' => MobileMoneyNetwork.airtelMoney,
        '8' => MobileMoneyNetwork.tnmMpamba,
        _ => null,
      };
    } on AuthFailure {
      return null;
    }
  }

  String get label => switch (this) {
    MobileMoneyNetwork.airtelMoney => 'Airtel Money',
    MobileMoneyNetwork.tnmMpamba => 'TNM Mpamba',
  };

  bool supports(MobileMoneyOperator operator) {
    final name = operator.name.toLowerCase();
    return switch (this) {
      MobileMoneyNetwork.airtelMoney => name.contains('airtel'),
      MobileMoneyNetwork.tnmMpamba =>
        name.contains('tnm') || name.contains('mpamba'),
    };
  }
}

MobileMoneyOperator? mobileMoneyOperatorForPhone(
  List<MobileMoneyOperator> operators,
  String phoneNumber,
) {
  final network = MobileMoneyNetwork.fromPhone(phoneNumber);
  if (network == null) return null;
  for (final operator in operators) {
    if (network.supports(operator)) return operator;
  }
  return null;
}
