import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/persistence/preferences_provider.dart';

part 'theme_mode_controller.g.dart';

@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  static const _key = 'appearance.theme_mode';

  @override
  Future<ThemeMode> build() async {
    try {
      final value = await ref.read(sharedPreferencesProvider).getString(_key);
      return switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } on Object {
      return ThemeMode.system;
    }
  }

  Future<void> select(ThemeMode mode) async {
    final previous = state.value ?? ThemeMode.system;
    state = AsyncData(mode);
    try {
      await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
    } on Object {
      state = AsyncData(previous);
      rethrow;
    }
  }
}
