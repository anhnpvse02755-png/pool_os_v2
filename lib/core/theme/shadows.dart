import 'package:flutter/material.dart';

/// PoolOS Design System - Elevation (Shadows)
class AppShadows {
  AppShadows._();

  // ========================================================================
  // LIGHT MODE SHADOWS
  // ========================================================================

  static List<BoxShadow> get lightSm => [
        const BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
        const BoxShadow(
          color: Color(0x05000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get lightMd => [
        const BoxShadow(
          color: Color(0x12000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
        const BoxShadow(
          color: Color(0x07000000),
          blurRadius: 6,
          offset: Offset(0, -1),
        ),
      ];

  static List<BoxShadow> get lightLg => [
        const BoxShadow(
          color: Color(0x14000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
        const BoxShadow(
          color: Color(0x08000000),
          blurRadius: 15,
          offset: Offset(0, -2),
        ),
      ];

  // ========================================================================
  // DARK MODE SHADOWS
  // ========================================================================

  static List<BoxShadow> get darkSm => [
        const BoxShadow(
          color: Color(0x4D000000),
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
        const BoxShadow(
          color: Color(0x26000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get darkMd => [
        const BoxShadow(
          color: Color(0x66000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
        const BoxShadow(
          color: Color(0x40000000),
          blurRadius: 6,
          offset: Offset(0, -1),
        ),
      ];

  static List<BoxShadow> get darkLg => [
        const BoxShadow(
          color: Color(0x80000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
        const BoxShadow(
          color: Color(0x50000000),
          blurRadius: 15,
          offset: Offset(0, -2),
        ),
      ];

  // ========================================================================
  // HELPER - Get shadows based on brightness
  // ========================================================================

  static List<BoxShadow> sm(Brightness brightness) =>
      brightness == Brightness.light ? lightSm : darkSm;

  static List<BoxShadow> md(Brightness brightness) =>
      brightness == Brightness.light ? lightMd : darkMd;

  static List<BoxShadow> lg(Brightness brightness) =>
      brightness == Brightness.light ? lightLg : darkLg;
}
