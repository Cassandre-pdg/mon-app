import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typographie Kolyb — Inter uniquement
/// Nom de marque : Inter 700, letterSpacing -0.02em
/// Slogan        : Inter 500, letterSpacing +0.03em
/// Corps         : Inter 400, lineHeight 1.5–1.6
class AppTextStyles {
  AppTextStyles._();

  // ── TITRES (Inter) ──────────────────────────────────────────
  static TextStyle displayLarge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle headingLarge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle headingMedium({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle headingSmall({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  // ── CORPS (Inter) ───────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodySmall({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle labelMedium({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle caption({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.grey400,
        height: 1.4,
      );

  // ── MARQUE ─────────────────────────────────────────────────
  /// "kolyb" — nom de marque dans le logo/splash
  static TextStyle brandName({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textDark,
        letterSpacing: -0.56, // -0.02em
      );

  /// "Ton élan, au quotidien." — slogan
  static TextStyle brandSlogan({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.primaryLight,
        letterSpacing: 0.45, // +0.03em
      );
}
