import 'auth_failure.dart';

class MalawiPhoneNumber {
  const MalawiPhoneNumber._(this.value);

  final String value;

  static MalawiPhoneNumber parse(String input) {
    var compact = input.replaceAll(RegExp(r'[\s()\-]'), '');
    if (compact.startsWith('+265')) {
      compact = compact.substring(4);
    } else if (compact.startsWith('265')) {
      compact = compact.substring(3);
    } else if (compact.startsWith('0')) {
      compact = compact.substring(1);
    }
    if (!RegExp(r'^[1-9]\d{8}$').hasMatch(compact)) {
      throw const AuthFailure(
        code: 'INVALID_PHONE_NUMBER',
        message: 'Enter a valid Malawi phone number.',
      );
    }
    return MalawiPhoneNumber._('265$compact');
  }

  String get display {
    final national = value.substring(3);
    return '+265 ${national.substring(0, 2)} '
        '${national.substring(2, 5)} '
        '${national.substring(5)}';
  }
}
