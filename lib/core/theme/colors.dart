import 'package:flutter/material.dart';

/// PoolOS Design System - Color Tokens
/// Based on Minimalist Luxury design philosophy
class AppColors {
  AppColors._();

  // ========================================================================
  // LIGHT MODE COLORS
  // ========================================================================

  // Background & Surface
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF9FAFB);

  // Text
  static const Color lightTextPrimary = Color(0xFF0A0A0A);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  // Borders & Dividers
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightBorderSubtle = Color(0xFFF3F4F6);

  // ========================================================================
  // DARK MODE COLORS
  // ========================================================================

  // Background & Surface
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF18181B);
  static const Color darkSurfaceElevated = Color(0xFF27272A);

  // Text
  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextTertiary = Color(0xFF71717A);

  // Borders & Dividers
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkBorderSubtle = Color(0xFF3F3F46);

  // ========================================================================
  // ACCENT COLORS (Both Modes)
  // ========================================================================

  // Primary Accent - Electric Blue (Premium, Trustworthy)
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF60A5FA);
  static const Color accentDark = Color(0xFF1D4ED8);
  static const Color accentSubtleLight = Color(0xFFEFF6FF);
  static const Color accentSubtleDark = Color(0xFF1E3A5F);

  // ========================================================================
  // SEMANTIC COLORS (Both Modes)
  // ========================================================================

  // Success - Emerald Green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successSubtleLight = Color(0xFFECFDF5);
  static const Color successSubtleDark = Color(0xFF064E3B);

  // Warning - Amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSubtleLight = Color(0xFFFFFBEB);
  static const Color warningSubtleDark = Color(0xFF78350F);

  // Error - Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSubtleLight = Color(0xFFFEF2F2);
  static const Color errorSubtleDark = Color(0xFF7F1D1D);

  // ========================================================================
  // SPECIAL COLORS
  // ========================================================================

  // Gold - Achievements, Premium
  static const Color gold = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFBBF24);

  // Streak - Day streaks, Fire
  static const Color streak = Color(0xFFF97316);
  static const Color streakLight = Color(0xFFFB923C);

  // ========================================================================
  // SHADOW COLORS
  // ========================================================================

  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x4D000000);

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Returns appropriate colors based on brightness
  static Color background(Brightness brightness) =>
      brightness == Brightness.light ? lightBackground : darkBackground;

  static Color surface(Brightness brightness) =>
      brightness == Brightness.light ? lightSurface : darkSurface;

  static Color surfaceElevated(Brightness brightness) =>
      brightness == Brightness.light ? lightSurfaceElevated : darkSurfaceElevated;

  static Color textPrimary(Brightness brightness) =>
      brightness == Brightness.light ? lightTextPrimary : darkTextPrimary;

  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.light ? lightTextSecondary : darkTextSecondary;

  static Color textTertiary(Brightness brightness) =>
      brightness == Brightness.light ? lightTextTertiary : darkTextTertiary;

  static Color border(Brightness brightness) =>
      brightness == Brightness.light ? lightBorder : darkBorder;

  static Color borderSubtle(Brightness brightness) =>
      brightness == Brightness.light ? lightBorderSubtle : darkBorderSubtle;

  static Color accentColor(Brightness brightness) =>
      brightness == Brightness.light ? accent : accentLight;

  static Color accentSubtle(Brightness brightness) =>
      brightness == Brightness.light ? accentSubtleLight : accentSubtleDark;
}
