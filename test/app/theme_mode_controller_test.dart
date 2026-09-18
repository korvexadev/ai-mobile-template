import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/app/theme/theme_mode_controller.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('appearance choice survives a new provider container', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          'appearance.theme_mode': 'dark',
        });
    final first = ProviderContainer();
    addTearDown(first.dispose);
    expect(await first.read(appThemeModeProvider.future), ThemeMode.dark);

    await first.read(appThemeModeProvider.notifier).select(ThemeMode.light);
    expect(first.read(appThemeModeProvider).value, ThemeMode.light);

    final second = ProviderContainer();
    addTearDown(second.dispose);
    expect(await second.read(appThemeModeProvider.future), ThemeMode.light);
  });
}
