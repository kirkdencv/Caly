//This is where the caly identity is stored. 
import 'package:flutter/material.dart';

const calyGold = Color(0xFFD9A400);
const calyInk = Color(0xFF1C1C1E);
const calyWarmPaper = Color(0xFFFFFDF8);
const calyWhite = Color(0xFFFFFFFF);
const calyMuted = Color(0xFF6F6F73);
const calyOutline = Color(0xFFE7E4DE);
const calyError = Color(0xFFC63A35);

const calySoftGold =Color(0xFFFFF4C2);

final calyLightScheme = ColorScheme.fromSeed(
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

final calyTextTheme = TextTheme(
  headlineSmall: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  ),
  titleLarge: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  ),
  bodyMedium: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
  labelSmall: TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400
  )
);


final calyTheme = ThemeData(
  useMaterial3: true,

  colorScheme: calyLightScheme,

  scaffoldBackgroundColor: calyLightScheme.surface,

  textTheme: calyTextTheme,

  dividerColor: calyLightScheme.outline,

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: calyLightScheme.primary,
      foregroundColor: calyLightScheme.onPrimary,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: calyWhite,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: calyOutline,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: calyOutline,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: calyGold,
        width: 1.5,
      ),
    ),
  ),
);
