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
  /// Fond principal — #0D0B1E
  static const Color backgroundDark = Color(0xFF0D0B1E);
  /// Surface des cards — #1A1836
  static const Color surfaceDark    = Color(0xFF1A1836);
  /// Surface élevée (modals, bottom sheets) — #22204A
  static const Color surfaceElevatedDark = Color(0xFF22204A);

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

  // ─── GLASS (cartes premium) ────────────────────────────────────
  /// Fond card dark — #1A1836
  static const Color glassDark   = Color(0xFF1A1836);
  /// Bordure glass — #22204A
  static const Color glassBorder = Color(0xFF22204A);
}
