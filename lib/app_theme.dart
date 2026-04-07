import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF154C9E);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color success = Color(0xFF0D7E4E);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFB91C1C);

  static ThemeData get light {
    // Base Manrope text theme from Google Fonts, then apply our color overrides
    final manropeTextTheme = GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: textPrimary,
        fontSize: 18,
      ),
      titleMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontSize: 16,
      ),
      titleSmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontSize: 14,
      ),
      bodyLarge: GoogleFonts.manrope(
        color: textPrimary,
        fontSize: 16,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.manrope(
        color: textSecondary,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.manrope(
        color: textMuted,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      textTheme: manropeTextTheme, // ← Google Fonts handles the font loading
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: Colors.white,
        surface: surface,
        background: background,
        error: error,
      ),
      scaffoldBackgroundColor: background,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        labelStyle: GoogleFonts.manrope(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
