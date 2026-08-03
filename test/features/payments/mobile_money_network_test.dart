import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/payments/domain/mobile_money_network.dart';
import 'package:mikozi_mobile/features/payments/domain/payment.dart';

void main() {
  const airtel = MobileMoneyOperator(id: 'airtel', name: 'Airtel Money');
  const tnm = MobileMoneyOperator(id: 'tnm', name: 'TNM Mpamba');
  const operators = [airtel, tnm];

  test('maps numbers beginning with 9 to Airtel Money', () {
    expect(
      MobileMoneyNetwork.fromPhone('+265 991 234 567'),
      MobileMoneyNetwork.airtelMoney,
    );
    expect(mobileMoneyOperatorForPhone(operators, '0991234567'), same(airtel));
  });

  test('maps numbers beginning with 8 to TNM Mpamba', () {
    expect(
      MobileMoneyNetwork.fromPhone('+265 881 234 567'),
      MobileMoneyNetwork.tnmMpamba,
    );
    expect(mobileMoneyOperatorForPhone(operators, '0881234567'), same(tnm));
  });

  test('does not guess a network for unsupported or invalid numbers', () {
    expect(MobileMoneyNetwork.fromPhone('0771234567'), isNull);
    expect(mobileMoneyOperatorForPhone(operators, '123'), isNull);
  });
}
