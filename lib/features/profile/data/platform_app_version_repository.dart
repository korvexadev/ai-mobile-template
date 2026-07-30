import 'package:package_info_plus/package_info_plus.dart';

import '../domain/app_version_repository.dart';

class PlatformAppVersionRepository implements AppVersionRepository {
  const PlatformAppVersionRepository();

  @override
  Future<String> read() async {
    final package = await PackageInfo.fromPlatform();
    return package.buildNumber.isEmpty
        ? package.version
        : '${package.version} (${package.buildNumber})';
  }
}
