import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color deepCanopy = Color(0xFF1B4332);
  static const Color sprout = Color(0xFF40916C);
  static const Color harvestGold = Color(0xFFD4A373);
  static const Color sunbakedClay = Color(0xFFFAEDCD);
  static const Color surface = Color(0xFFFEFAE0);
  static const Color richLoam = Color(0xFF283618);

  static ThemeData get lightTheme {
    // We use Noto Serif for headings, Noto Sans for body (both support Sinhala/Tamil well)
    final TextTheme baseTextTheme = GoogleFonts.notoSansTextTheme();
    final TextTheme serifTextTheme = GoogleFonts.notoSerifTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: deepCanopy,
        secondary: sprout,
        tertiary: harvestGold,
        surface: surface,
        background: sunbakedClay,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: richLoam,
        onBackground: richLoam,
      ),
      scaffoldBackgroundColor: sunbakedClay,
      appBarTheme: AppBarTheme(
        backgroundColor: deepCanopy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: serifTextTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: serifTextTheme.displayLarge?.copyWith(color: richLoam),
        displayMedium: serifTextTheme.displayMedium?.copyWith(color: richLoam),
        displaySmall: serifTextTheme.displaySmall?.copyWith(color: richLoam),
        headlineLarge: serifTextTheme.headlineLarge?.copyWith(color: richLoam),
        headlineMedium: serifTextTheme.headlineMedium?.copyWith(color: richLoam),
        headlineSmall: serifTextTheme.headlineSmall?.copyWith(color: richLoam),
        titleLarge: serifTextTheme.titleLarge?.copyWith(color: richLoam, fontWeight: FontWeight.bold),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: richLoam),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: richLoam),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: richLoam),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sprout,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: baseTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: deepCanopy.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Organic roundness
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: sprout, width: 2),
        ),
        hintStyle: TextStyle(color: deepCanopy.withOpacity(0.5)),
      ),
    );
  }
}
