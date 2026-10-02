import 'package:flutter/material.dart';

const calyGold = Color(0xFFD9A400);
const calyInk = Color(0xFF1C1C1E);
const calyWarmPaper = Color(0xFFFFFDF8);
const calyWhite = Color(0xFFFFFFFF);
const calyMuted = Color(0xFF6F6F73);
const calyOutline = Color(0xFFE7E4DE);
const calyError = Color(0xFFC63A35);
const calySoftGold = Color(0xFFFFF4C2);
const calyDarkPaper = Color(0xFF121210);
const calyDarkSurface = Color(0xFF1C1C1A);
const calyDarkOutline = Color(0xFF383834);

final calyLightScheme =
    ColorScheme.fromSeed(
      seedColor: calyGold,
      brightness: Brightness.light,
    ).copyWith(
      primary: calyGold,
      onPrimary: calyInk,
      secondary: calySoftGold,
      onSecondary: calyInk,
      surface: calyWarmPaper,
      surfaceContainer: calyWhite,
      onSurface: calyInk,
      onSurfaceVariant: calyMuted,
      outline: calyOutline,
      error: calyError,
      onError: calyWhite,
    );

const calyTextTheme = TextTheme(
  headlineSmall: TextStyle(
    fontSize: 30,
    height: 1.12,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.7,
    fontFamilyFallback: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI'],
  ),
  titleLarge: TextStyle(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    fontFamilyFallback: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI'],
  ),
  bodyMedium: TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.15,
    fontFamilyFallback: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI'],
  ),
  labelSmall: TextStyle(
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.05,
    fontFamilyFallback: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI'],
  ),
);

ThemeData _buildCalyTheme(ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: calyTextTheme,
    dividerColor: scheme.outline,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainer,
      modalBackgroundColor: scheme.surfaceContainer,
      showDragHandle: true,
      dragHandleColor: scheme.outline,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 60,
      backgroundColor: scheme.surface,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: calyGold,
        foregroundColor: calyInk,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: calyGold, width: 1.5),
      ),
    ),
  );
}

final calyTheme = _buildCalyTheme(calyLightScheme);

final calyDarkTheme = _buildCalyTheme(
  ColorScheme.fromSeed(
    seedColor: calyGold,
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFFE9B72D),
    onPrimary: calyInk,
    secondary: const Color(0xFF4A3E19),
    onSecondary: const Color(0xFFFFF3C4),
    surface: calyDarkPaper,
    surfaceContainer: calyDarkSurface,
    onSurface: const Color(0xFFF4F1EA),
    onSurfaceVariant: const Color(0xFFB8B5AE),
    outline: calyDarkOutline,
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
  ),
);
