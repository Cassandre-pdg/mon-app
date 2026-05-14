import 'package:flutter/material.dart';

/// Palette Kolyb — Brand Guidelines officiel
/// Jamais de hardcode ailleurs dans le code
class AppColors {
  AppColors._();

  // ─── PRIMAIRES ────────────────────────────────────────────────
  /// Violet profond — couleur structurante principale
  static const Color primary      = Color(0xFF6D28D9);
  static const Color primaryLight = Color(0xFF8B7FE8); // accent / hover / pills
  static const Color primaryDark  = Color(0xFF4A1A9E); // variant sombre

  /// Violet clair — textes sur fond sombre, labels
  static const Color primaryPale  = Color(0xFFC4B5FD);

  /// Corail — énergie, alertes
  static const Color secondary    = Color(0xFFFF4D6A);

  /// Teal — succès, graphiques
  static const Color accent       = Color(0xFF00D4C8);

  // ─── GRAPHIQUES ───────────────────────────────────────────────
  static const Color chartAmber  = Color(0xFFFFB800); // warnings, badges, 3e série
  static const Color chartViolet = Color(0xFF8B7FE8); // 2e série, éléments actifs

  // ─── FONDS DARK MODE (défaut) ────────────────────────────────
  /// Fond principal — top du gradient (couleur de fallback)
  static const Color backgroundDark = Color(0xFF000000);
  /// Gradient dark : haut → bas, 180°
  static const Color backgroundDarkGradientStart = Color(0xFF000000); // noir pur
  static const Color backgroundDarkGradientEnd   = Color(0xFF11044D); // indigo nuit
  /// Surface des cards — légèrement plus claire pour du volume sur le gradient
  static const Color surfaceDark    = Color(0xFF160F3A);
  /// Surface élevée (modals, bottom sheets) — plus présent pour l'effet depth
  static const Color surfaceElevatedDark = Color(0xFF1E1650);

  // ─── FONDS LIGHT MODE ─────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF5F4FF); // blanc cassé violet
  static const Color surfaceLight    = Color(0xFFFFFFFF); // cards

  // ─── TEXTE ────────────────────────────────────────────────────
  static const Color textDark      = Color(0xFFEDEDFF); // blanc doux (sur fond dark)
  static const Color textDarkMuted = Color(0x80EDEDED); // blanc 50% — labels, captions
  static const Color textLight     = Color(0xFF12122A); // quasi-noir (sur fond light)

  // ─── ÉTATS ────────────────────────────────────────────────────
  static const Color success = Color(0xFF00D4C8); // = accent teal
  static const Color warning = Color(0xFFFFB800); // = amber
  static const Color error   = Color(0xFFFF4D6A); // = corail

  // ─── NEUTRES ──────────────────────────────────────────────────
  static const Color grey100 = Color(0xFFF2F2F8);
  static const Color grey200 = Color(0xFFE0E0EF);
  static const Color grey400 = Color(0xFF9898B0);
  static const Color grey600 = Color(0xFF5C5C7A);
  static const Color grey800 = Color(0xFF22204A); // = bordure Kolyb

  // ─── GLASS / LIQUID GLASS ─────────────────────────────────────
  /// Fond card dark — légèrement remonté pour volume sur gradient
  static const Color glassDark        = Color(0xFF160F3A);
  /// Bordure glass — highlight subtil pour l'effet depth Apple
  static const Color glassBorder      = Color(0xFF2A1E6E);
  /// Highlight top-edge card (trait de lumière 1px en haut)
  static const Color glassHighlight   = Color(0x14FFFFFF); // blanc 8%
  /// Fond glassmorphism blanc 8% (sur fond aurora/coloré)
  static const Color glassWhite8      = Color(0x14FFFFFF);
  /// Fond glassmorphism blanc 12%
  static const Color glassWhite12     = Color(0x1FFFFFFF);
  /// Bordure glass blanche semi-transparente
  static const Color glassBorderWhite = Color(0x1AFFFFFF);

  // ─── AURORA (orbes animées background) ────────────────────────
  static const Color auroraViolet = Color(0x668B7FE8); // primaryLight 40%
  static const Color auroraPink   = Color(0x66FF4D6A); // secondary 40%
  static const Color auroraTeal   = Color(0x6600D4C8); // accent 40%
  static const Color auroraAmber  = Color(0x66FFB800); // chartAmber 40%
  static const Color auroraCorail = Color(0x66FF4D6A); // = auroraPink

  // ─── GRADIENTS (listes const pour LinearGradient) ────────────
  /// Gradient principal : violet clair → violet pâle → teal
  static const List<Color> gradientMain   = [Color(0xFF8B7FE8), Color(0xFFC4B5FD), Color(0xFF00D4C8)];
  /// Gradient violet : profond → pâle
  static const List<Color> gradientViolet = [Color(0xFF6D28D9), Color(0xFFC4B5FD)];
  /// Gradient énergie : corail → amber
  static const List<Color> gradientEnergy = [Color(0xFFFF4D6A), Color(0xFFFFB800)];
  /// Gradient dark pour GlassDarkCard : violet semi-transparent
  static const List<Color> gradientDark   = [Color(0x2A6D28D9), Color(0x1A4A1A9E)];
}
