import 'package:flutter/material.dart';

const calyGold = Color(0xFFD9A400);
const calyInk = Color(0xFF1C1C1E);
const calyWarmPaper = Color(0xFFFFFDF8);
const calyWhite = Color(0xFFFFFFFF);
const calyMuted = Color(0xFF6F6F73);
const calyOutline = Color(0xFFE7E4DE);
const calyError = Color(0xFFC63A35);
const calySoftGold = Color(0xFFFFF4C2);

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
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  ),
  titleLarge: TextStyle(fontSize: 24, height: 1.2, fontWeight: FontWeight.w700),
  bodyMedium: TextStyle(
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w400,
  ),
  labelSmall: TextStyle(fontSize: 13, height: 1.3, fontWeight: FontWeight.w400),
);

final calyTheme = ThemeData(
  useMaterial3: true,
  colorScheme: calyLightScheme,
  scaffoldBackgroundColor: calyLightScheme.surface,
  textTheme: calyTextTheme,
  dividerColor: calyLightScheme.outline,
  appBarTheme: const AppBarTheme(
    backgroundColor: calyWarmPaper,
    foregroundColor: calyInk,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: calyWhite,
    modalBackgroundColor: calyWhite,
    showDragHandle: true,
    dragHandleColor: calyOutline,
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 72,
    backgroundColor: calyWarmPaper,
    indicatorColor: Colors.transparent,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      return TextStyle(
        fontSize: 12,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w600
            : FontWeight.w400,
        color: states.contains(WidgetState.selected) ? calyGold : calyMuted,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      return IconThemeData(
        color: states.contains(WidgetState.selected) ? calyGold : calyMuted,
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
    fillColor: const Color(0xFFF7F5F1),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(color: calyMuted),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: calyOutline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: calyOutline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: calyGold, width: 1.5),
    ),
  ),
);
