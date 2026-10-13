import 'package:flutter/material.dart';

/// Digital Inertia Design System Colors
/// Built on the requested Instrument Sans monochrome palette:
/// - #212529: Primary Dark, Deep Charcoal, Text, High-contrast Surfaces
/// - #f5f6f7: Soft Light Grey Canvas Background & Subtle Card Contrasts
/// - #ffffff: Pure White Cards, Elevated Surfaces, Input Fills
class AppColors {
  AppColors._();

  // The 3 Core Palette Colors
  static const Color primaryDark = Color(0xFF212529);     // #212529
  static const Color backgroundLight = Color(0xFFF5F6F7);  // #f5f6f7
  static const Color cardLight = Color(0xFFFFFFFF);        // #ffffff
  static const Color primaryWhite = Color(0xFFFFFFFF);

  // Dark / Obsidian tones aligned with #212529
  static const Color obsidianBlack = Color(0xFF212529);
  static const Color slateCardDark = Color(0xFF2B3035);
  static const Color surfaceElevatedDark = Color(0xFF343A40);
  static const Color borderDark = Color(0xFF495057);

  // Light tones aligned with #f5f6f7 and #ffffff
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color inputFill = Color(0xFFFFFFFF);

  // High contrast monochrome accents
  static const Color electricBlue = Color(0xFF212529);
  static const Color electricBlueLight = Color(0xFFE9ECEF);
  static const Color electricBlueMuted = Color(0xFF495057);

  // Status indicator colors (Exceptions, Alerts & Health)
  static const Color statusOverdue = Color(0xFFE03131); // Red
  static const Color statusOverdueLight = Color(0xFFFFF5F5);

  static const Color statusInProgress = Color(0xFFF59F00); // Amber
  static const Color statusInProgressLight = Color(0xFFFFF9DB);

  static const Color statusCompleted = Color(0xFF2F9E44); // Emerald Green
  static const Color statusCompletedLight = Color(0xFFEBFBEE);

  static const Color statusReview = Color(0xFF7048E8); // Violet
  static const Color statusReviewLight = Color(0xFFF3F0FF);

  static const Color statusMuted = Color(0xFF868E96); // Slate
  static const Color statusMutedLight = Color(0xFFF1F3F5);

  // Typography neutral colors
  static const Color textPrimary = Color(0xFF212529);     // #212529
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFFADB5BD);
  static const Color textLight = Color(0xFFF5F6F7);       // #f5f6f7
  static const Color textLightSecondary = Color(0xFFCED4DA);
}
