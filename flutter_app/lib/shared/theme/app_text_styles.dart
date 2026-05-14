import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typographie Kolyb — Inter uniquement
/// Nom de marque : Inter 700, letterSpacing -0.02em
/// Slogan        : Inter 500, letterSpacing +0.03em
/// Corps         : Inter 400, lineHeight 1.5–1.6
class AppTextStyles {
  AppTextStyles._();

  // ── HÉROS / DISPLAY (chiffres & titres impact) ──────────────
  /// Chiffre héros — streak, points, timer : 56px ultra-bold
  static TextStyle heroNumber({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textDark,
        height: 1.0,
        letterSpacing: -1.5,
      );

  /// Display extra-large — 48px, titres de section héros
  static TextStyle displayXL({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textDark,
        height: 1.05,
        letterSpacing: -1.2,
      );

  // ── TITRES (Inter) ──────────────────────────────────────────
  static TextStyle displayLarge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.1,
        letterSpacing: -0.8,
      );

  static TextStyle headingLarge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle headingMedium({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle headingSmall({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
        letterSpacing: -0.1,
      );

  // ── CORPS (Inter) ───────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.6,
      );

  static TextStyle bodyMedium({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.55,
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

  static TextStyle labelSmall({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
        letterSpacing: 0.06,
      );

  static TextStyle caption({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.grey400,
        height: 1.4,
      );

  /// Overline — uppercase micro label
  static TextStyle overline({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.grey400,
        height: 1.3,
        letterSpacing: 0.08,
      );

  // ── MARQUE ─────────────────────────────────────────────────
  /// "kolyb" — nom de marque dans le logo/splash
  static TextStyle brandName({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textDark,
        letterSpacing: -1.0,
      );

  /// "Ton élan, au quotidien." — slogan
  static TextStyle brandSlogan({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.primaryLight,
        letterSpacing: 0.45,
      );

  // ── UTILITAIRES GRADIENT (ShaderMask) ───────────────────────
  /// Applique un gradient sur un texte
  static Widget gradientText(
    String text,
    TextStyle style, {
    List<Color>? colors,
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) {
    final grad = colors ?? AppColors.gradientMain;
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: grad,
        begin: begin,
        end: end,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style),
    );
  }

  /// Gradient main : violet → pale → teal (titres hero)
  static Widget gradientMain(String text, {TextStyle? style, double? fontSize}) =>
      gradientText(
        text,
        style ?? displayLarge().copyWith(fontSize: fontSize),
        colors: AppColors.gradientMain,
      );

  /// Gradient energy : corail → amber (CTA, mots d'action)
  static Widget gradientEnergy(String text, {TextStyle? style, double? fontSize}) =>
      gradientText(
        text,
        style ?? headingLarge().copyWith(fontSize: fontSize),
        colors: AppColors.gradientEnergy,
      );

  /// Gradient violet : violet profond → pale (accents doux)
  static Widget gradientViolet(String text, {TextStyle? style, double? fontSize}) =>
      gradientText(
        text,
        style ?? headingLarge().copyWith(fontSize: fontSize),
        colors: AppColors.gradientViolet,
      );
}
