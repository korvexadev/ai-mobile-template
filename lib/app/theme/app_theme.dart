import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const brandRed = Color(0xFFC62E3A);
  static const brandRedDark = Color(0xFF9E202B);
  static const ink = Color(0xFF18191C);
  static const paper = Color(0xFFFAF9F6);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFF707178);
  static const border = Color(0xFFE4E2DD);
  static const softSurface = Color(0xFFF2F0EB);
  static const error = Color(0xFFB4232D);

  static const darkPaper = Color(0xFF141518);
  static const darkSurface = Color(0xFF202126);
  static const darkSoftSurface = Color(0xFF292B31);
  static const darkInk = Color(0xFFF5F2ED);
  static const darkMuted = Color(0xFFB5B5BC);
  static const darkBorder = Color(0xFF3C3E45);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color paperOf(BuildContext context) =>
      isDark(context) ? darkPaper : paper;
  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : white;
  static Color softSurfaceOf(BuildContext context) =>
      isDark(context) ? darkSoftSurface : softSurface;
  static Color inkOf(BuildContext context) => isDark(context) ? darkInk : ink;
  static Color mutedOf(BuildContext context) =>
      isDark(context) ? darkMuted : muted;
  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static const ColorScheme _colors = ColorScheme(
    brightness: Brightness.light,
    primary: brandRed,
    onPrimary: white,
    primaryContainer: Color(0xFFFFDADC),
    onPrimaryContainer: Color(0xFF46000A),
    secondary: Color(0xFF655A5A),
    onSecondary: white,
    secondaryContainer: Color(0xFFF0DDDC),
    onSecondaryContainer: Color(0xFF251818),
    tertiary: Color(0xFF6B5D2F),
    onTertiary: white,
    tertiaryContainer: Color(0xFFF4E2A7),
    onTertiaryContainer: Color(0xFF221B00),
    error: error,
    onError: white,
    errorContainer: Color(0xFFFFDAD9),
    onErrorContainer: Color(0xFF410007),
    surface: paper,
    onSurface: ink,
    surfaceContainerHighest: softSurface,
    onSurfaceVariant: muted,
    outline: Color(0xFF8D8986),
    outlineVariant: border,
    shadow: Color(0x1F000000),
    scrim: Color(0x66000000),
    inverseSurface: Color(0xFF303033),
    onInverseSurface: Color(0xFFF4F0EF),
    inversePrimary: Color(0xFFFFB2B7),
    surfaceTint: brandRed,
  );

  static ThemeData get light {
    final textTheme = _textTheme;
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _colors,
      scaffoldBackgroundColor: paper,
      canvasColor: paper,
      fontFamily: 'Manrope',
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        toolbarHeight: 64,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        hintStyle: textTheme.bodyLarge?.copyWith(color: muted),
        labelStyle: textTheme.bodyMedium,
        errorStyle: textTheme.bodySmall?.copyWith(color: error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandRed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: brandRed,
          foregroundColor: white,
          disabledBackgroundColor: border,
          disabledForegroundColor: muted,
          elevation: 0,
          shape: rounded,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: ink,
          side: const BorderSide(color: border),
          elevation: 0,
          shape: rounded,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandRed,
          minimumSize: const Size(44, 44),
          textStyle: textTheme.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFFFE7E8),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected) ? brandRed : muted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: white),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: rounded,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: brandRed,
        linearTrackColor: border,
        circularTrackColor: border,
      ),
    );
  }

  static ThemeData get dark {
    final colors =
        ColorScheme.fromSeed(
          seedColor: brandRed,
          brightness: Brightness.dark,
          surface: darkPaper,
        ).copyWith(
          primary: const Color(0xFFFF7780),
          onPrimary: darkPaper,
          surface: darkPaper,
          onSurface: darkInk,
          onSurfaceVariant: darkMuted,
          outline: darkMuted,
          outlineVariant: darkBorder,
          surfaceContainerHighest: darkSoftSurface,
        );
    final text = _textTheme.apply(bodyColor: darkInk, displayColor: darkInk);
    return light.copyWith(
      brightness: Brightness.dark,
      colorScheme: colors,
      scaffoldBackgroundColor: darkPaper,
      canvasColor: darkPaper,
      textTheme: text,
      primaryTextTheme: text,
      appBarTheme: light.appBarTheme.copyWith(foregroundColor: darkInk),
      inputDecorationTheme: light.inputDecorationTheme.copyWith(
        fillColor: darkSurface,
        hintStyle: text.bodyLarge?.copyWith(color: darkMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
      ),
      cardTheme: light.cardTheme.copyWith(color: darkSurface),
      dividerTheme: const DividerThemeData(color: darkBorder),
      navigationBarTheme: light.navigationBarTheme.copyWith(
        backgroundColor: darkSurface,
        indicatorColor: darkSoftSurface,
      ),
      bottomSheetTheme: light.bottomSheetTheme.copyWith(
        backgroundColor: darkPaper,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFFF7780),
        linearTrackColor: darkBorder,
        circularTrackColor: darkBorder,
      ),
    );
  }

  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        color: ink,
        fontFamily: 'Manrope',
        fontSize: 50,
        fontWeight: FontWeight.w700,
        height: 1,
        letterSpacing: -1.2,
      ),
      displayMedium: TextStyle(
        color: ink,
        fontFamily: 'Manrope',
        fontSize: 42,
        fontWeight: FontWeight.w700,
        height: 1.04,
        letterSpacing: -1,
      ),
      displaySmall: TextStyle(
        color: ink,
        fontFamily: 'Manrope',
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.06,
        letterSpacing: -0.9,
      ),
      headlineLarge: TextStyle(
        color: ink,
        fontFamily: 'Manrope',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.7,
      ),
      headlineMedium: TextStyle(
        color: ink,
        fontFamily: 'Manrope',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.6,
      ),
      headlineSmall: TextStyle(
        color: ink,
        fontFamily: 'Manrope',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: ink,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.45,
      ),
      titleMedium: TextStyle(
        color: ink,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      titleSmall: TextStyle(
        color: ink,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        color: ink,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.55,
        letterSpacing: -0.1,
      ),
      bodyMedium: TextStyle(
        color: muted,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: muted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    );
  }
}
