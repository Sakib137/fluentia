import 'package:flutter/material.dart';

/// Centralized corner radii tokens for Fluentia.
/// Follows moderate curvature to preserve a professional and calm aesthetic.
class AppRadii {
  AppRadii._();

  /// 0px - Sharp corners
  static const double none = 0.0;

  /// 4px - Micro tags, subtle indicators
  static const double xs = 4.0;

  /// 8px - Small chips, tooltips
  static const double sm = 8.0;

  /// 12px - Buttons, text inputs, smaller cards
  static const double md = 12.0;

  /// 16px - Standard cards, dialogs, bottom sheets
  static const double lg = 16.0;

  /// 20px - Prominent hero cards
  static const double xl = 20.0;

  /// 24px - Large containers and modal sheets
  static const double xxl = 24.0;

  /// 999px - Circular avatars, streak counters, and pill badges
  static const double full = 999.0;

  // BorderRadius Constants
  static const BorderRadius roundedNone = BorderRadius.zero;
  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius roundedFull = BorderRadius.all(
    Radius.circular(full),
  );

  // Semantic Component Presets
  static const BorderRadius card = roundedLg;
  static const BorderRadius button = roundedMd;
  static const BorderRadius input = roundedMd;
  static const BorderRadius badge = roundedFull;
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
}
