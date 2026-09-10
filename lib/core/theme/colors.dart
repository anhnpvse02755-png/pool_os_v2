import 'package:flutter/material.dart';

/// PoolOS Design System - Color Tokens
/// Based on Minimalist Luxury design philosophy
class AppColors {
  AppColors._();

  // ========================================================================
  // LIGHT MODE COLORS
  // ========================================================================

  // Background & Surface
  static const Color lightBackground = Color(0xFFF7F4EC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightSurfaceRecessed = Color(0xFFF1EFEA);

  // Text
  static const Color lightTextPrimary = Color(0xFF12352B);
  static const Color lightTextSecondary = Color(0xFF5E6661);
  static const Color lightTextTertiary = Color(0xFF9AA39D);

  // Borders & Dividers
  static const Color lightBorder = Color(0xFFE7E3DA);
  static const Color lightBorderSubtle = Color(0xFFF0EDE5);

  // ========================================================================
  // DARK MODE COLORS
  // ========================================================================

  // Background & Surface
  static const Color darkBackground = Color(0xFF121715);
  static const Color darkSurface = Color(0xFF1B221F);
  static const Color darkSurfaceElevated = Color(0xFF232B27);
  static const Color darkSurfaceRecessed = Color(0xFF171D1A);

  // Text
  static const Color darkTextPrimary = Color(0xFFECF1EE);
  static const Color darkTextSecondary = Color(0xFF9AA6A0);
  static const Color darkTextTertiary = Color(0xFF6F7B75);

  // Borders & Dividers
  static const Color darkBorder = Color(0xFF2C3531);
  static const Color darkBorderSubtle = Color(0xFF242C29);

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
  // XANH RÊU — MÀU CHÍNH
  // ========================================================================

  static const Color lightPrimary = Color(0xFF0F4032);
  static const Color lightPrimaryDeep = Color(0xFF08291F);
  static const Color lightPrimaryContainer = Color(0xFF0F4032);
  static const Color lightAccentLabel = Color(0xFF0F7A55);

  static const Color darkPrimary = Color(0xFF34A97C);
  static const Color darkPrimaryDeep = Color(0xFF2A8A65);
  static const Color darkPrimaryContainer = Color(0xFF16382C);
  static const Color darkAccentLabel = Color(0xFF4FC79A);

  // ========================================================================
  // BLOB NỀN — đặt sau lớp nền, opacity thấp
  // ========================================================================

  static const Color lightBlobPeach = Color(0xFFFBE9DC);
  static const Color lightBlobMint = Color(0xFFDFEFE4);
  static const Color lightBlobButter = Color(0xFFFDF6E3);

  static const Color darkBlobPeach = Color(0xFF2A1E18);
  static const Color darkBlobMint = Color(0xFF16241E);
  static const Color darkBlobButter = Color(0xFF262214);

  // ========================================================================
  // Ô PASTEL — gán theo danh mục ỔN ĐỊNH, không ngẫu nhiên.
  // Người dùng học được màu, nên cùng một danh mục phải luôn cùng tông.
  // ========================================================================

  static const List<Color> pastelLight = [
    Color(0xFFDCEFE5), // mint
    Color(0xFFDCE7F7), // blue
    Color(0xFFFBE7DA), // peach
    Color(0xFFEAE3F7), // lilac
    Color(0xFFFBF0D5), // butter
  ];

  static const List<Color> pastelDark = [
    Color(0xFF1C3830),
    Color(0xFF1B2A3C),
    Color(0xFF38281F),
    Color(0xFF2A2438),
    Color(0xFF33301F),
  ];

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

  /// Màu chữ/icon đặt TRÊN nền [primary].
  ///
  /// Đảo chiều theo chế độ, không phải lúc nào cũng trắng: chế độ tối primary
  /// là #34A97C (xanh sáng) nên chữ trắng chỉ đạt ~2.5:1 — không đọc được.
  static Color onPrimary(Brightness brightness) =>
      brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF08201A);

  /// Nền dịu cho hộp lỗi / cảnh báo / thành công.
  ///
  /// Có accessor riêng vì màn hình nào cũng cần, và trước đây mỗi màn tự
  /// hardcode bản sáng — dark mode ra nền trắng chói trên nền than.
  static Color errorSubtle(Brightness brightness) =>
      brightness == Brightness.light ? errorSubtleLight : errorSubtleDark;

  static Color warningSubtle(Brightness brightness) =>
      brightness == Brightness.light ? warningSubtleLight : warningSubtleDark;

  static Color successSubtle(Brightness brightness) =>
      brightness == Brightness.light ? successSubtleLight : successSubtleDark;

  static Color primary(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimary : darkPrimary;

  static Color primaryDeep(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimaryDeep : darkPrimaryDeep;

  static Color primaryContainer(Brightness brightness) =>
      brightness == Brightness.light
          ? lightPrimaryContainer
          : darkPrimaryContainer;

  static Color accentLabel(Brightness brightness) =>
      brightness == Brightness.light ? lightAccentLabel : darkAccentLabel;

  static Color surfaceRecessed(Brightness brightness) =>
      brightness == Brightness.light
          ? lightSurfaceRecessed
          : darkSurfaceRecessed;

  /// Tông pastel thứ [index], lặn vòng khi vượt quá 5.
  static Color pastelFor(int index, Brightness brightness) {
    final palette = brightness == Brightness.light ? pastelLight : pastelDark;
    return palette[index % palette.length];
  }
}
