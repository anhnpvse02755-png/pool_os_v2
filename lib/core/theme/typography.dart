import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PoolOS Design System - Typography
/// Font Family: Plus Jakarta Sans
class AppTypography {
  AppTypography._();

  static String get _fontFamily => GoogleFonts.plusJakartaSans().fontFamily!;

  // ========================================================================
  // DISPLAY - Hero numbers, big stats
  // ========================================================================

  static TextStyle display({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color,
      );

  // ========================================================================
  // HEADINGS
  // ========================================================================

  static TextStyle h1({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  static TextStyle h2({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  static TextStyle h3({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  // ========================================================================
  // BODY TEXT
  // ========================================================================

  static TextStyle bodyLarge({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle body({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color,
      );

  // ========================================================================
  // SMALL TEXT
  // ========================================================================

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  static TextStyle captionMedium({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  // ========================================================================
  // LABELS - Category labels, tabs (uppercase)
  // ========================================================================

  static TextStyle label({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.5,
        color: color,
      );

  // ========================================================================
  // BUTTON TEXT
  // ========================================================================

  static TextStyle button({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color,
      );

  static TextStyle buttonLarge({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: color,
      );

  // ========================================================================
  // NEW STYLES — Task 3
  // ========================================================================

  /// Tiêu đề trang — "Thể thức thi đấu"
  static TextStyle get displayLg => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
      );

  /// Tiêu đề thẻ / tên người chơi — trong thiết kế tham chiếu, tên người
  /// chơi to gần bằng tiêu đề trang.
  static TextStyle get cardTitle => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  /// Nhãn hành động — "Chọn làm người bắn"
  static TextStyle get actionLabel => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );
}
