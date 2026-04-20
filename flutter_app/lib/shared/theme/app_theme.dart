import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Thème global Kolyb — Brand Guidelines officiel
class AppTheme {
  AppTheme._();

  // ── DARK MODE ───────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textDark,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        textTheme: _buildTextTheme(AppColors.textDark),
        appBarTheme: _appBarTheme(
          background: AppColors.backgroundDark,
          foreground: AppColors.textDark,
        ),
        cardTheme: _cardTheme(AppColors.surfaceDark),
        elevatedButtonTheme: _elevatedButtonTheme(),
        outlinedButtonTheme: _outlinedButtonTheme(),
        iconButtonTheme: _iconButtonTheme(),
        inputDecorationTheme: _inputTheme(isDark: true),
        bottomNavigationBarTheme: _bottomNavTheme(isDark: true),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF1E1E32),
          thickness: 1,
        ),
        tabBarTheme: _tabBarTheme(),
      );

  // ── LIGHT MODE ──────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceLight,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textLight,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: _buildTextTheme(AppColors.textLight),
        appBarTheme: _appBarTheme(
          background: AppColors.backgroundLight,
          foreground: AppColors.textLight,
        ),
        cardTheme: _cardTheme(AppColors.surfaceLight),
        elevatedButtonTheme: _elevatedButtonTheme(),
        outlinedButtonTheme: _outlinedButtonTheme(),
        iconButtonTheme: _iconButtonTheme(),
        inputDecorationTheme: _inputTheme(isDark: false),
        bottomNavigationBarTheme: _bottomNavTheme(isDark: false),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFEEEEF5),
          thickness: 1,
        ),
        tabBarTheme: _tabBarTheme(),
      );

  // ── COMPOSANTS ──────────────────────────────────────────────

  static TextTheme _buildTextTheme(Color baseColor) =>
      GoogleFonts.interTextTheme().copyWith(
        displayLarge:   GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: baseColor, letterSpacing: -0.5),
        headlineLarge:  GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: baseColor, letterSpacing: -0.3),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: baseColor),
        titleLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: baseColor),
        bodyLarge:      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: baseColor),
        bodyMedium:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: baseColor),
        bodySmall:      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: baseColor),
        labelMedium:    GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: baseColor),
      );

  static AppBarTheme _appBarTheme({required Color background, required Color foreground}) =>
      AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: foreground,
          letterSpacing: -0.4,
        ),
      );

  static CardThemeData _cardTheme(Color surface) => CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      );

  // ── Bouton principal — pill style Apple/Revolut ─────────────
  static ElevatedButtonThemeData _elevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          // Pill complet — style Apple
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          // Largeur contrainte — jamais plein écran
          minimumSize: const Size(180, 52),
          maximumSize: const Size(320, 56),
        ).copyWith(
          // Effet glow subtil au repos
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => Colors.white.withValues(alpha: 0.08),
          ),
        ),
      );

  // ── Bouton secondaire — pill outline ────────────────────────
  static OutlinedButtonThemeData _outlinedButtonTheme() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          minimumSize: const Size(160, 48),
          maximumSize: const Size(320, 52),
        ),
      );

  // ── IconButton — cercle semi-transparent ────────────────────
  static IconButtonThemeData _iconButtonTheme() =>
      IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          foregroundColor: AppColors.primary,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          minimumSize: const Size(48, 48),
          maximumSize: const Size(56, 56),
        ),
      );

  static InputDecorationTheme _inputTheme({required bool isDark}) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceElevatedDark
            : AppColors.grey100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.glassBorder : AppColors.grey200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.grey400,
          fontSize: 14,
        ),
      );

  static BottomNavigationBarThemeData _bottomNavTheme({required bool isDark}) =>
      BottomNavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey600,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        elevation: 0,
      );

  static TabBarThemeData _tabBarTheme() => TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey400,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
      );
}
