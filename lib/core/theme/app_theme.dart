import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Brand Colors
  static const Color primary = Color(0xFF047857); // Deep Emerald Green
  static const Color secondary = Color(0xFF10B981); // Vibrant Emerald
  static const Color tertiary = Color(0xFFD97706); // Warm Amber/Gold
  static const Color background = Color(0xFFF9FAFB); // Crisp Off-White
  static const Color surface = Colors.white; // Pure White
  static const Color textDark = Color(0xFF111827); // Near Black for crisp text
  static const Color textLight = Color(0xFF6B7280); // Subtle Gray

  static ThemeData getLightTheme(String languageCode) {
    TextTheme bodyTextTheme;
    TextTheme headingTextTheme;

    if (languageCode == 'si') {
      bodyTextTheme = GoogleFonts.notoSansSinhalaTextTheme();
      headingTextTheme = GoogleFonts.notoSansSinhalaTextTheme();
    } else if (languageCode == 'ta') {
      bodyTextTheme = GoogleFonts.notoSansTamilTextTheme();
      headingTextTheme = GoogleFonts.notoSansTamilTextTheme();
    } else {
      bodyTextTheme = GoogleFonts.interTextTheme();
      headingTextTheme = GoogleFonts.poppinsTextTheme();
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
        onBackground: textDark,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingTextTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: bodyTextTheme.copyWith(
        displayLarge: headingTextTheme.displayLarge?.copyWith(color: textDark, fontWeight: FontWeight.bold),
        displayMedium: headingTextTheme.displayMedium?.copyWith(color: textDark, fontWeight: FontWeight.bold),
        displaySmall: headingTextTheme.displaySmall?.copyWith(color: textDark, fontWeight: FontWeight.w600),
        headlineLarge: headingTextTheme.headlineLarge?.copyWith(color: textDark, fontWeight: FontWeight.w600),
        headlineMedium: headingTextTheme.headlineMedium?.copyWith(color: textDark, fontWeight: FontWeight.w600),
        headlineSmall: headingTextTheme.headlineSmall?.copyWith(color: textDark, fontWeight: FontWeight.w600),
        titleLarge: headingTextTheme.titleLarge?.copyWith(color: textDark, fontWeight: FontWeight.w600),
        titleMedium: headingTextTheme.titleMedium?.copyWith(color: textDark, fontWeight: FontWeight.w500),
        titleSmall: headingTextTheme.titleSmall?.copyWith(color: textDark, fontWeight: FontWeight.w500),
        bodyLarge: bodyTextTheme.bodyLarge?.copyWith(color: textDark, fontSize: 16),
        bodyMedium: bodyTextTheme.bodyMedium?.copyWith(color: textDark, fontSize: 14),
        bodySmall: bodyTextTheme.bodySmall?.copyWith(color: textLight, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Slightly squarer for a premium modern look
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: headingTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1, // Soft shadow
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return bodyTextTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return bodyTextTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: textLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 28);
          }
          return const IconThemeData(color: textLight, size: 24);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: TextStyle(color: textLight),
      ),
    );
  }
}
