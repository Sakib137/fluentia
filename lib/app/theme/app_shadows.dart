import 'package:flutter/material.dart';

/// Centralized restrained elevation and shadow definitions for Fluentia.
/// Avoids heavy, distracting drop shadows in favor of soft, natural depth.
class AppShadows {
  AppShadows._();

  // --- Light Mode Shadows ---
  static const List<BoxShadow> none = [];

  /// Very soft separation (e.g. subtle hover or flat cards)
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x060F172A), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Standard card resting elevation
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Elevated buttons, floating action items, dropdown menus
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x120F172A), blurRadius: 16, offset: Offset(0, 4)),
  ];

  /// Modal dialogs and persistent bottom sheets
  static const List<BoxShadow> modal = [
    BoxShadow(color: Color(0x1C0F172A), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // --- Dark Mode Shadows ---
  static const List<BoxShadow> darkSubtle = [
    BoxShadow(color: Color(0x28000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> darkCard = [
    BoxShadow(color: Color(0x38000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> darkFloating = [
    BoxShadow(color: Color(0x50000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
}
