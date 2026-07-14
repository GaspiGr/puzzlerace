import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de colores
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF13131C);
  static const Color surface2 = Color(0xFF1C1C2E);
  static const Color accent = Color(0xFFF0C040);
  static const Color accentOrange = Color(0xFFE06030);
  static const Color accentBlue = Color(0xFF40B0F0);
  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textMuted = Color(0xFF7878A0);
  static const Color border = Color(0xFF2A2A3E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentBlue,
        surface: surface,
        error: accentOrange,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(
        const TextTheme(
          // Display
          displayLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 48,
            letterSpacing: -1.5,
          ),
          displayMedium: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 36,
            letterSpacing: -1.0,
          ),
          // Headings
          headlineLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
          // Body
          bodyLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: textMuted,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            color: textMuted,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          // Label
          labelLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
    );
  }
}
