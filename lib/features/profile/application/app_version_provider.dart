import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/platform_app_version_repository.dart';
import '../domain/app_version_repository.dart';

part 'app_version_provider.g.dart';

@Riverpod(keepAlive: true)
AppVersionRepository appVersionRepository(Ref ref) {
  return const PlatformAppVersionRepository();
}

@riverpod
Future<String> appVersion(Ref ref) {
  return ref.watch(appVersionRepositoryProvider).read();
}
