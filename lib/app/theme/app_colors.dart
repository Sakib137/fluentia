import 'package:flutter/material.dart';

/// Central design tokens for Fluentia's color palette.
/// Curated for a calm, intelligent, and premium aesthetic.
class AppColors {
  AppColors._();

  // Primary Brand - Sophisticated Teal / Deep Green
  static const Color primary50 = Color(0xFFF0FDFA);
  static const Color primary100 = Color(0xFFCCFBF1);
  static const Color primary200 = Color(0xFF99F6E4);
  static const Color primary300 = Color(0xFF5EEAD4);
  static const Color primary400 = Color(0xFF2DD4BF);
  static const Color primary500 = Color(0xFF14B8A6);
  static const Color primary600 = Color(0xFF0D9488); // Main Brand Accent
  static const Color primary700 = Color(0xFF0F766E);
  static const Color primary800 = Color(0xFF115E59);
  static const Color primary900 = Color(0xFF134E4A);

  // Primary convenience aliases
  static const Color primary = primary600;
  static const Color primaryLight = primary500;
  static const Color primaryDark = primary700;

  // Teal Scale (Brand Primary Teal Palette)
  static const Color teal50 = primary50;
  static const Color teal100 = primary100;
  static const Color teal200 = primary200;
  static const Color teal300 = primary300;
  static const Color teal400 = primary400;
  static const Color teal500 = primary500;
  static const Color teal600 = primary600;
  static const Color teal700 = primary700;
  static const Color teal800 = primary800;
  static const Color teal900 = primary900;

  // Slate Neutral Scale (Surfaces & Text)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF090D16);

  // Accent - Sage / Success (Encouraging / Streaks / Progress)
  static const Color sage50 = Color(0xFFF0FDF4);
  static const Color sage100 = Color(0xFFDCFCE7);
  static const Color sage200 = Color(0xFFBBF7D0);
  static const Color sage400 = Color(0xFF4ADE80);
  static const Color sage500 = Color(0xFF22C55E);
  static const Color sage600 = Color(0xFF16A34A);
  static const Color sage700 = Color(0xFF15803D);

  // Semantic - Warning / Attention (Amber)
  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning200 = Color(0xFFFDE68A);
  static const Color warning400 = Color(0xFFFBBF24);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning600 = Color(0xFFD97706);
  static const Color amber500 = warning500;

  // Semantic - Error / Destructive (Coral)
  static const Color error50 = Color(0xFFFEF2F2);
  static const Color error100 = Color(0xFFFFE4E6);
  static const Color error200 = Color(0xFFFECDD3);
  static const Color error400 = Color(0xFFF87171);
  static const Color error500 = Color(0xFFEF4444);
  static const Color error600 = Color(0xFFDC2626);
  static const Color coral500 = error500;

  // Semantic Aliases
  static const Color success50 = sage50;
  static const Color success100 = sage100;
  static const Color success200 = sage200;
  static const Color success300 = sage200;
  static const Color success400 = sage400;
  static const Color success500 = sage500;
  static const Color success600 = sage600;
  static const Color success700 = sage700;
  static const Color success800 = sage700;
  static const Color success900 = Color(0xFF14532D);

  static const Color danger50 = error50;
  static const Color danger100 = error100;
  static const Color danger200 = error200;
  static const Color danger300 = error200;
  static const Color danger400 = error400;
  static const Color danger500 = error500;
  static const Color danger600 = error600;
  static const Color danger700 = Color(0xFFB91C1C);
  static const Color danger800 = Color(0xFF991B1B);
  static const Color danger900 = Color(0xFF7F1D1D);

  static const Color warning300 = warning200;
  static const Color warning700 = warning600;
  static const Color warning800 = Color(0xFFB45309);
  static const Color warning900 = Color(0xFF78350F);

  // Semantic - Info (Sky)
  static const Color info50 = Color(0xFFEFF6FF);
  static const Color info100 = Color(0xFFDBEAFE);
  static const Color info400 = Color(0xFF60A5FA);
  static const Color info500 = Color(0xFF3B82F6);
  static const Color info600 = Color(0xFF2563EB);
  static const Color sky500 = info500;

  // Surface Tokens - Light Mode
  static const Color lightBackground = slate50;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = slate100;
  static const Color lightSurfaceSecondary = slate100;
  static const Color lightBorder = slate200;
  static const Color lightBorderSubtle = slate100;
  static const Color lightTextPrimary = slate900;
  static const Color lightTextSecondary = slate600;
  static const Color lightTextMuted = slate400;

  // Surface Tokens - Dark Mode
  static const Color darkBackground = slate950;
  static const Color darkSurface = Color(0xFF131B2A);
  static const Color darkSurfaceVariant = slate800;
  static const Color darkSurfaceElevated = slate800;
  static const Color darkBorder = Color(0xFF222F43);
  static const Color darkBorderSubtle = Color(0xFF1A2436);
  static const Color darkTextPrimary = slate50;
  static const Color darkTextSecondary = slate300;
  static const Color darkTextMuted = slate500;

  // Absolute / Functional
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Shadows
  static const Color lightShadow = Color(0x0A0F172A);
  static const Color darkShadow = Color(0x40000000);
}
