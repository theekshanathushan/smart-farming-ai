import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Brand Colors (Light)
  static const Color primary = Color(0xFF047857); // Deep Emerald Green
  static const Color primaryLight = Color(0xFF10B981); // Bright Emerald
  static const Color secondary = Color(0xFF059669); // Forest Emerald
  static const Color tertiary = Color(0xFFD97706); // Warm Amber/Gold
  static const Color background = Color(0xFFF8FAFC); // Crisp Off-White Slate 50
  static const Color surface = Colors.white; // Pure White
  static const Color surfaceContainer = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0); // Slate 200
  static const Color textDark = Color(0xFF0F172A); // Deep Slate 900 for high readability
  static const Color textLight = Color(0xFF475569); // Slate 600 for crisp subtext
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color outlineLight = Color(0xFFE2E8F0); // Subtle Border

  // Dark Mode Palette (Obsidian & Emerald)
  static const Color darkPrimary = Color(0xFF10B981); // Bright Luminous Emerald
  static const Color darkSecondary = Color(0xFF34D399); // Mint Accent
  static const Color darkTertiary = Color(0xFFFBBF24); // Warm Gold Accent
  static const Color darkBackground = Color(0xFF0B1320); // Deep Obsidian Navy
  static const Color darkSurface = Color(0xFF131F30); // Elevated Dark Card Surface
  static const Color darkSurfaceContainer = Color(0xFF1A2A40); // Slightly more elevated container
  static const Color darkSurfaceContainerHigh = Color(0xFF243650); // High elevation container
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Crisp Pure White
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Cool Slate 400
  static const Color darkTextMuted = Color(0xFF64748B); // Slate 500
  static const Color outlineDark = Color(0xFF1E293B); // Dark Border

  static TextTheme _buildBodyTextTheme(String languageCode) {
    if (languageCode == 'si') {
      return GoogleFonts.notoSansSinhalaTextTheme();
    } else if (languageCode == 'ta') {
      return GoogleFonts.notoSansTamilTextTheme();
    } else {
      return GoogleFonts.interTextTheme();
    }
  }

  static TextTheme _buildHeadingTextTheme(String languageCode) {
    if (languageCode == 'si') {
      return GoogleFonts.notoSansSinhalaTextTheme();
    } else if (languageCode == 'ta') {
      return GoogleFonts.notoSansTamilTextTheme();
    } else {
      return GoogleFonts.poppinsTextTheme();
    }
  }

  static ThemeData getLightTheme(String languageCode) {
    final bodyTextTheme = _buildBodyTextTheme(languageCode);
    final headingTextTheme = _buildHeadingTextTheme(languageCode);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: textDark,
        onSurfaceVariant: textLight,
        outline: outlineLight,
        outlineVariant: Color(0xFFCBD5E1),
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingTextTheme.titleLarge?.copyWith(
          color: textDark,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      textTheme: bodyTextTheme.copyWith(
        displayLarge: headingTextTheme.displayLarge?.copyWith(color: textDark, fontWeight: FontWeight.bold),
        displayMedium: headingTextTheme.displayMedium?.copyWith(color: textDark, fontWeight: FontWeight.bold),
        displaySmall: headingTextTheme.displaySmall?.copyWith(color: textDark, fontWeight: FontWeight.w600),
        headlineLarge: headingTextTheme.headlineLarge?.copyWith(color: textDark, fontWeight: FontWeight.w700),
        headlineMedium: headingTextTheme.headlineMedium?.copyWith(color: textDark, fontWeight: FontWeight.w700),
        headlineSmall: headingTextTheme.headlineSmall?.copyWith(color: textDark, fontWeight: FontWeight.w600),
        titleLarge: headingTextTheme.titleLarge?.copyWith(color: textDark, fontWeight: FontWeight.bold),
        titleMedium: headingTextTheme.titleMedium?.copyWith(color: textDark, fontWeight: FontWeight.w600),
        titleSmall: headingTextTheme.titleSmall?.copyWith(color: textDark, fontWeight: FontWeight.w600),
        bodyLarge: bodyTextTheme.bodyLarge?.copyWith(color: textDark, fontSize: 16),
        bodyMedium: bodyTextTheme.bodyMedium?.copyWith(color: textDark, fontSize: 14),
        bodySmall: bodyTextTheme.bodySmall?.copyWith(color: textLight, fontSize: 12),
        labelLarge: headingTextTheme.labelLarge?.copyWith(color: textDark, fontWeight: FontWeight.w600),
        labelMedium: headingTextTheme.labelMedium?.copyWith(color: textLight, fontWeight: FontWeight.w500),
        labelSmall: headingTextTheme.labelSmall?.copyWith(color: textMuted, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: headingTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: headingTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: headingTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: outlineLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        selectedColor: primary,
        labelStyle: TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        side: const BorderSide(color: outlineLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: headingTextTheme.titleLarge?.copyWith(color: textDark, fontWeight: FontWeight.bold),
        contentTextStyle: bodyTextTheme.bodyMedium?.copyWith(color: textDark),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return bodyTextTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
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
          borderSide: const BorderSide(color: outlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textLight),
      ),
      dividerTheme: const DividerThemeData(
        color: outlineLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData getDarkTheme(String languageCode) {
    final bodyTextTheme = _buildBodyTextTheme(languageCode);
    final headingTextTheme = _buildHeadingTextTheme(languageCode);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        tertiary: darkTertiary,
        surface: darkSurface,
        surfaceContainer: darkSurfaceContainer,
        surfaceContainerHigh: darkSurfaceContainerHigh,
        onPrimary: Color(0xFF06281E), // Deep dark green for high contrast text on bright emerald
        onSecondary: Color(0xFF06281E),
        onTertiary: Color(0xFF281806),
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextSecondary,
        outline: outlineDark,
        outlineVariant: Color(0xFF334155),
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingTextTheme.titleLarge?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary),
      ),
      textTheme: bodyTextTheme.copyWith(
        displayLarge: headingTextTheme.displayLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: headingTextTheme.displayMedium?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.bold),
        displaySmall: headingTextTheme.displaySmall?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w600),
        headlineLarge: headingTextTheme.headlineLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w700),
        headlineMedium: headingTextTheme.headlineMedium?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w700),
        headlineSmall: headingTextTheme.headlineSmall?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleLarge: headingTextTheme.titleLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.bold),
        titleMedium: headingTextTheme.titleMedium?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleSmall: headingTextTheme.titleSmall?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: bodyTextTheme.bodyLarge?.copyWith(color: darkTextPrimary, fontSize: 16),
        bodyMedium: bodyTextTheme.bodyMedium?.copyWith(color: darkTextPrimary, fontSize: 14),
        bodySmall: bodyTextTheme.bodySmall?.copyWith(color: darkTextSecondary, fontSize: 12),
        labelLarge: headingTextTheme.labelLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w600),
        labelMedium: headingTextTheme.labelMedium?.copyWith(color: darkTextSecondary, fontWeight: FontWeight.w500),
        labelSmall: headingTextTheme.labelSmall?.copyWith(color: darkTextMuted, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: const Color(0xFF042F22), // High contrast dark text on vibrant emerald
          elevation: 2,
          shadowColor: darkPrimary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: headingTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: headingTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          textStyle: headingTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceContainer,
        selectedColor: darkPrimary,
        labelStyle: const TextStyle(color: darkTextPrimary, fontSize: 13, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: Color(0xFF042F22), fontSize: 13, fontWeight: FontWeight.bold),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: headingTextTheme.titleLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.bold),
        contentTextStyle: bodyTextTheme.bodyMedium?.copyWith(color: darkTextPrimary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: darkPrimary.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return bodyTextTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: darkPrimary,
            );
          }
          return bodyTextTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: darkPrimary, size: 28);
          }
          return const IconThemeData(color: darkTextSecondary, size: 24);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: darkTextMuted),
        labelStyle: const TextStyle(color: darkTextSecondary),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
