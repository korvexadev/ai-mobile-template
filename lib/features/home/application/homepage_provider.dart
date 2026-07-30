import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/networking/mikozi_api_client.dart';
import '../../../core/networking/network_providers.dart';
import '../data/remote_homepage_repository.dart';
import '../domain/homepage.dart';

part 'homepage_provider.g.dart';

@Riverpod(keepAlive: true)
HomepageRepository homepageRepository(Ref ref) {
  return RemoteHomepageRepository(MikoziApiClient(ref.watch(dioProvider)));
}

@riverpod
Future<Homepage> homepage(Ref ref) {
  return ref.watch(homepageRepositoryProvider).fetch();
}
