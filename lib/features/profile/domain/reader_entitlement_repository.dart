import 'reader_entitlement.dart';

abstract interface class ReaderEntitlementRepository {
  Future<ReaderEntitlement> fetch();
}

class ReaderEntitlementFailure implements Exception {
  const ReaderEntitlementFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
