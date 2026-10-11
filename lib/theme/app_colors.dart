import 'package:flutter/material.dart';

/// Digital Inertia Design System Colors
/// Matches the minimalist, high-contrast monochrome + electric blue palette
/// demonstrated in the CEO ERP mobile design specs.
class AppColors {
  AppColors._();

  // Dark obsidian tones (as seen in Splash screen)
  static const Color obsidianBlack = Color(0xFF0D1217);
  static const Color slateCardDark = Color(0xFF161E27);
  static const Color surfaceElevatedDark = Color(0xFF1E2834);
  static const Color borderDark = Color(0xFF263342);

  // Light tones (as seen in Login / Biometric screen)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color inputFill = Color(0xFFF8FAFC);

  // High contrast primary controls
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  
  // Electric Blue accent (fingerprint icon & active highlights)
  static const Color electricBlue = Color(0xFF2563EB);
  static const Color electricBlueLight = Color(0xFFEFF6FF);
  static const Color electricBlueMuted = Color(0xFF3B82F6);

  // Status indicator colors (Exceptions & Operational Health)
  static const Color statusOverdue = Color(0xFFEF4444); // Red
  static const Color statusOverdueLight = Color(0xFFFEF2F2);
  
  static const Color statusInProgress = Color(0xFFF59E0B); // Amber
  static const Color statusInProgressLight = Color(0xFFFFFBEB);
  
  static const Color statusCompleted = Color(0xFF10B981); // Emerald Green
  static const Color statusCompletedLight = Color(0xFFECFDF5);
  
  static const Color statusReview = Color(0xFF8B5CF6); // Purple
  static const Color statusReviewLight = Color(0xFFF5F3FF);

  static const Color statusMuted = Color(0xFF64748B); // Slate
  static const Color statusMutedLight = Color(0xFFF1F5F9);

  // Neutral text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textLightSecondary = Color(0xFF94A3B8);
}
