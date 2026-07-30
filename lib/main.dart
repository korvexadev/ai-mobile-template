import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mikozi_mobile/app/router/app_router.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';

const mikoziLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  DefaultMaterialLocalizations.delegate,
  DefaultCupertinoLocalizations.delegate,
  DefaultWidgetsLocalizations.delegate,
];

void main() {
  runApp(const ProviderScope(child: MikoziApp()));
}

class MikoziApp extends ConsumerWidget {
  const MikoziApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveApp.router(
      title: 'Mikozi',
      themeMode: ThemeMode.light,
      localizationsDelegates: mikoziLocalizationsDelegates,
      materialLightTheme: AppTheme.light,
      cupertinoLightTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppTheme.brandRed,
        scaffoldBackgroundColor: AppTheme.paper,
        barBackgroundColor: AppTheme.paper,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(color: AppTheme.ink, fontFamily: 'Manrope'),
          navTitleTextStyle: TextStyle(
            color: AppTheme.ink,
            fontFamily: 'Manrope',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
