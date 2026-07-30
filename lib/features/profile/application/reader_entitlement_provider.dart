import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/networking/mikozi_api_client.dart';
import '../../../core/networking/network_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../data/remote_reader_entitlement_repository.dart';
import '../domain/reader_entitlement.dart';
import '../domain/reader_entitlement_repository.dart';

part 'reader_entitlement_provider.g.dart';

@Riverpod(keepAlive: true)
ReaderEntitlementRepository readerEntitlementRepository(Ref ref) {
  return RemoteReaderEntitlementRepository(
    MikoziApiClient(ref.watch(dioProvider)),
    () async {
      final session = await ref
          .read(authControllerProvider.notifier)
          .validSession();
      return session?.tokens.accessToken;
    },
  );
}

@riverpod
Future<ReaderEntitlement> readerEntitlement(Ref ref) {
  return ref.watch(readerEntitlementRepositoryProvider).fetch();
}
