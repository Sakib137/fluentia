import 'package:flutter/material.dart';

/// Centralized spacing tokens and layout padding presets for Fluentia.
/// Aligned to an 8pt architectural grid with 4pt half-steps.
class AppSpacing {
  AppSpacing._();

  // Spacing Scale
  /// 2px - Micro separation
  static const double xxs = 2.0;

  /// 4px - Tight element spacing
  static const double xs = 4.0;

  /// 8px - Compact element spacing, icon gaps
  static const double sm = 8.0;

  /// 12px - Medium spacing, internal card gaps
  static const double md = 12.0;

  /// 16px - Standard spacing, default card margins, list gaps
  static const double lg = 16.0;

  /// 20px - Relaxed content spacing
  static const double xl = 20.0;

  /// 24px - Large section padding
  static const double xxl = 24.0;

  /// 32px - Prominent layout gaps
  static const double xxxl = 32.0;

  /// 48px - Major section dividers
  static const double section = 48.0;

  // Component Heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 54.0;
  static const double buttonHeight = buttonHeightMd;
  static const double inputHeight = 48.0;
  static const double cardMinHeight = 64.0;

  // Layout Padding Presets
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingDense = EdgeInsets.all(md);
  static const EdgeInsets modalPadding = EdgeInsets.all(xxl);

  // Spacing Gap SizedBoxes (Performance-optimized const widgets)
  static const SizedBox gapHorizontalXs = SizedBox(width: xs);
  static const SizedBox gapHorizontalSm = SizedBox(width: sm);
  static const SizedBox gapHorizontalMd = SizedBox(width: md);
  static const SizedBox gapHorizontalLg = SizedBox(width: lg);
  static const SizedBox gapHorizontalXl = SizedBox(width: xl);

  static const SizedBox gapVerticalXs = SizedBox(height: xs);
  static const SizedBox gapVerticalSm = SizedBox(height: sm);
  static const SizedBox gapVerticalMd = SizedBox(height: md);
  static const SizedBox gapVerticalLg = SizedBox(height: lg);
  static const SizedBox gapVerticalXl = SizedBox(height: xl);
  static const SizedBox gapVerticalXxl = SizedBox(height: xxl);
  static const SizedBox gapVerticalSection = SizedBox(height: section);

  // Backward-compatible Corner Radii & Icon Sizing
  static const BorderRadius roundedNone = BorderRadius.zero;
  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(20.0));
  static const BorderRadius roundedFull = BorderRadius.all(
    Radius.circular(999.0),
  );

  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 40.0;
  static const double iconHero = 48.0;
}
