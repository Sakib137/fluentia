import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_font_sizes.dart';
import 'app_font_weights.dart';

/// Centralized typographic scale for Fluentia.
/// Optimized for maximum readability, calmness, and clear visual hierarchy.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto'; // Clean fallback font family

  // Line Heights
  static const double lineHeightTight = 1.25;
  static const double lineHeightSnug = 1.35;
  static const double lineHeightNormal = 1.45;
  static const double lineHeightRelaxed = 1.55;

  // Letter Spacings
  static const double letterSpacingTight = -0.6;
  static const double letterSpacingCompressed = -0.3;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingExpanded = 0.15;
  static const double letterSpacingWide = 0.3;

  /// Complete Light TextTheme
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: AppFontSizes.displayLarge,
      fontWeight: AppFontWeights.bold,
      letterSpacing: -0.8,
      height: lineHeightTight,
      color: AppColors.lightTextPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: AppFontSizes.displayMedium,
      fontWeight: AppFontWeights.bold,
      letterSpacing: letterSpacingTight,
      height: lineHeightTight,
      color: AppColors.lightTextPrimary,
    ),
    displaySmall: TextStyle(
      fontSize: AppFontSizes.displaySmall,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: letterSpacingCompressed,
      height: lineHeightSnug,
      color: AppColors.lightTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: AppFontSizes.headlineLarge,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: letterSpacingCompressed,
      height: lineHeightSnug,
      color: AppColors.lightTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: AppFontSizes.headlineMedium,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: letterSpacingCompressed,
      height: lineHeightSnug,
      color: AppColors.lightTextPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: AppFontSizes.headlineSmall,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: -0.2,
      height: lineHeightNormal,
      color: AppColors.lightTextPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: AppFontSizes.titleLarge,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: -0.1,
      height: lineHeightNormal,
      color: AppColors.lightTextPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: AppFontSizes.titleMedium,
      fontWeight: AppFontWeights.medium,
      letterSpacing: letterSpacingNormal,
      height: lineHeightNormal,
      color: AppColors.slate800,
    ),
    titleSmall: TextStyle(
      fontSize: AppFontSizes.titleSmall,
      fontWeight: AppFontWeights.medium,
      letterSpacing: letterSpacingExpanded,
      height: lineHeightNormal,
      color: AppColors.lightTextSecondary,
    ),
    bodyLarge: TextStyle(
      fontSize: AppFontSizes.bodyLarge,
      fontWeight: AppFontWeights.regular,
      letterSpacing: letterSpacingExpanded,
      height: lineHeightRelaxed,
      color: AppColors.slate800,
    ),
    bodyMedium: TextStyle(
      fontSize: AppFontSizes.bodyMedium,
      fontWeight: AppFontWeights.regular,
      letterSpacing: letterSpacingExpanded,
      height: lineHeightRelaxed,
      color: AppColors.lightTextSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: AppFontSizes.bodySmall,
      fontWeight: AppFontWeights.regular,
      letterSpacing: letterSpacingWide,
      height: lineHeightNormal,
      color: AppColors.lightTextMuted,
    ),
    labelLarge: TextStyle(
      fontSize: AppFontSizes.labelLarge,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: letterSpacingExpanded,
      height: lineHeightNormal,
      color: AppColors.lightTextPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: AppFontSizes.labelMedium,
      fontWeight: AppFontWeights.medium,
      letterSpacing: letterSpacingWide,
      height: lineHeightNormal,
      color: AppColors.lightTextSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: AppFontSizes.labelSmall,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: letterSpacingWide,
      height: lineHeightNormal,
      color: AppColors.lightTextMuted,
    ),
  );

  /// Complete Dark TextTheme
  static TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: AppFontSizes.displayLarge,
      fontWeight: AppFontWeights.bold,
      letterSpacing: -0.8,
      height: lineHeightTight,
      color: AppColors.darkTextPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: AppFontSizes.displayMedium,
      fontWeight: AppFontWeights.bold,
      letterSpacing: letterSpacingTight,
      height: lineHeightTight,
      color: AppColors.darkTextPrimary,
    ),
    displaySmall: TextStyle(
      fontSize: AppFontSizes.displaySmall,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: letterSpacingCompressed,
      height: lineHeightSnug,
      color: AppColors.darkTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: AppFontSizes.headlineLarge,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: letterSpacingCompressed,
      height: lineHeightSnug,
      color: AppColors.darkTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: AppFontSizes.headlineMedium,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: letterSpacingCompressed,
      height: lineHeightSnug,
      color: AppColors.darkTextPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: AppFontSizes.headlineSmall,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: -0.2,
      height: lineHeightNormal,
      color: AppColors.darkTextPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: AppFontSizes.titleLarge,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: -0.1,
      height: lineHeightNormal,
      color: AppColors.darkTextPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: AppFontSizes.titleMedium,
      fontWeight: AppFontWeights.medium,
      letterSpacing: letterSpacingNormal,
      height: lineHeightNormal,
      color: AppColors.darkTextSecondary,
    ),
    titleSmall: TextStyle(
      fontSize: AppFontSizes.titleSmall,
      fontWeight: AppFontWeights.medium,
      letterSpacing: letterSpacingExpanded,
      height: lineHeightNormal,
      color: AppColors.slate400,
    ),
    bodyLarge: TextStyle(
      fontSize: AppFontSizes.bodyLarge,
      fontWeight: AppFontWeights.regular,
      letterSpacing: letterSpacingExpanded,
      height: lineHeightRelaxed,
      color: AppColors.darkTextSecondary,
    ),
    bodyMedium: TextStyle(
      fontSize: AppFontSizes.bodyMedium,
      fontWeight: AppFontWeights.regular,
      letterSpacing: letterSpacingExpanded,
      height: lineHeightRelaxed,
      color: AppColors.slate400,
    ),
    bodySmall: TextStyle(
      fontSize: AppFontSizes.bodySmall,
      fontWeight: AppFontWeights.regular,
      letterSpacing: letterSpacingWide,
      height: lineHeightNormal,
      color: AppColors.darkTextMuted,
    ),
    labelLarge: TextStyle(
      fontSize: AppFontSizes.labelLarge,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: letterSpacingExpanded,
      height: lineHeightNormal,
      color: AppColors.darkTextPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: AppFontSizes.labelMedium,
      fontWeight: AppFontWeights.medium,
      letterSpacing: letterSpacingWide,
      height: lineHeightNormal,
      color: AppColors.darkTextSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: AppFontSizes.labelSmall,
      fontWeight: AppFontWeights.semiBold,
      letterSpacing: letterSpacingWide,
      height: lineHeightNormal,
      color: AppColors.darkTextMuted,
    ),
  );

  /// Additional caption text styles for sub-captions and metadata
  static TextStyle captionLight = TextStyle(
    fontSize: AppFontSizes.caption,
    fontWeight: AppFontWeights.medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
    color: AppColors.lightTextMuted,
  );

  static TextStyle captionDark = TextStyle(
    fontSize: AppFontSizes.caption,
    fontWeight: AppFontWeights.medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
    color: AppColors.darkTextMuted,
  );
}
