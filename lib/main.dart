import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';

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
          textStyle: TextStyle(
            color: AppTheme.ink,
            fontFamily: 'Manrope',
            fontSize: 15,
          ),
          actionTextStyle: TextStyle(
            color: AppTheme.brandRed,
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          tabLabelTextStyle: TextStyle(
            color: AppTheme.ink,
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          navTitleTextStyle: TextStyle(
            color: AppTheme.ink,
            fontFamily: 'Manrope',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          navLargeTitleTextStyle: TextStyle(
            color: AppTheme.ink,
            fontFamily: 'Manrope',
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
          navActionTextStyle: TextStyle(
            color: AppTheme.brandRed,
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
