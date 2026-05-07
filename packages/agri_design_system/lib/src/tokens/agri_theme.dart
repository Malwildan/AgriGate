
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'agri_colors.dart';
import 'agri_typography.dart';

abstract final class AgriTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AgriColors.background,
        textTheme: AgriTypography.textTheme,
        appBarTheme: _appBarTheme,
        cardTheme: _cardTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
        dividerTheme: _dividerTheme,
        pageTransitionsTheme: _pageTransitionsTheme,
      );

  static ColorScheme get _colorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: AgriColors.lime,
        onPrimary: AgriColors.forest,
        primaryContainer: AgriColors.limeDark,
        onPrimaryContainer: AgriColors.forest,
        secondary: AgriColors.forest,
        onSecondary: Color(0xFFF0EDE1),
        secondaryContainer: AgriColors.forestDeep,
        onSecondaryContainer: Color(0xFFF0EDE1),
        surface: AgriColors.card,
        onSurface: AgriColors.ink,
        surfaceContainerHighest: AgriColors.backgroundAlt,
        error: AgriColors.error,
        onError: AgriColors.onError,
        outline: AgriColors.border,
        outlineVariant: AgriColors.borderStrong,
      );

  static AppBarTheme get _appBarTheme => const AppBarTheme(
        backgroundColor: AgriColors.background,
        foregroundColor: AgriColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AgriColors.background,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

  static CardThemeData get _cardTheme => CardThemeData(
        color: AgriColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AgriColors.border),
        ),
        margin: EdgeInsets.zero,
      );

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AgriColors.lime,
          foregroundColor: AgriColors.forest,
          elevation: 0,
          minimumSize: const Size.fromHeight(60),
          shape: const StadiumBorder(),
          textStyle: AgriTypography.ctaButton,
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AgriColors.ink,
          side: const BorderSide(color: AgriColors.borderStrong, width: 1.5),
          minimumSize: const Size(60, 60),
          shape: const CircleBorder(),
        ),
      );

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F5ED),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AgriColors.borderStrong, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AgriColors.borderStrong, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AgriColors.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AgriColors.error, width: 1.5),
        ),
      );

  static DividerThemeData get _dividerTheme => const DividerThemeData(
        color: AgriColors.borderStrong,
        thickness: 1,
        space: 0,
      );

  static PageTransitionsTheme get _pageTransitionsTheme =>
      const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      );
}
