import 'package:mikozi_mobile/core/networking/mikozi_api_client.dart';
import 'package:mikozi_mobile/core/networking/network_providers.dart';
import 'package:mikozi_mobile/features/home/data/remote_homepage_repository.dart';
import 'package:mikozi_mobile/features/home/domain/homepage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'homepage_provider.g.dart';

@Riverpod(keepAlive: true)
HomepageRepository homepageRepository(Ref ref) {
  return RemoteHomepageRepository(MikoziApiClient(ref.watch(dioProvider)));
}

@riverpod
Future<Homepage> homepage(Ref ref) {
  return ref.watch(homepageRepositoryProvider).fetch();
}
