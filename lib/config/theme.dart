import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Toss-style theme configuration
/// Design Direction: Clean, modern, trustworthy
class AppTheme {
  AppTheme._();

  // ============================================================
  // TOSS COLOR PALETTE - Light Mode
  // ============================================================
  static const Color primaryLight = Color(0xFF3182F6); // Toss Blue
  static const Color backgroundLight = Color(0xFFF4F5F7); // Light Gray
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color textPrimaryLight = Color(0xFF191F28); // Almost Black
  static const Color textSecondaryLight = Color(0xFF8B95A1); // Medium Gray
  static const Color textTertiaryLight = Color(0xFFB0B8C1); // Light Gray
  static const Color borderLight = Color(0xFFE5E8EB); // Subtle border

  // ============================================================
  // TOSS COLOR PALETTE - Dark Mode
  // ============================================================
  static const Color primaryDark = Color(0xFF4A9DFF); // Brighter Blue for dark
  static const Color backgroundDark = Color(0xFF17171C); // Dark background
  static const Color surfaceDark = Color(0xFF1F1F26); // Dark surface
  static const Color textPrimaryDark = Color(0xFFF2F4F6); // Almost White
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Medium Gray
  static const Color textTertiaryDark = Color(0xFF6B7280); // Darker Gray
  static const Color borderDark = Color(0xFF2D2D35); // Dark border

  // ============================================================
  // SHARED COLORS
  // ============================================================
  static const Color success = Color(0xFF00C471); // Toss Green
  static const Color error = Color(0xFFF04452); // Toss Red
  static const Color warning = Color(0xFFFF9500); // Orange

  // ============================================================
  // DYNAMIC COLORS (Use these in widgets)
  // ============================================================
  static Color primary = primaryLight;
  static Color background = backgroundLight;
  static Color surface = surfaceLight;
  static Color textPrimary = textPrimaryLight;
  static Color textSecondary = textSecondaryLight;
  static Color textTertiary = textTertiaryLight;
  static Color border = borderLight;

  static void setDarkMode(bool isDark) {
    if (isDark) {
      primary = primaryDark;
      background = backgroundDark;
      surface = surfaceDark;
      textPrimary = textPrimaryDark;
      textSecondary = textSecondaryDark;
      textTertiary = textTertiaryDark;
      border = borderDark;
    } else {
      primary = primaryLight;
      background = backgroundLight;
      surface = surfaceLight;
      textPrimary = textPrimaryLight;
      textSecondary = textSecondaryLight;
      textTertiary = textTertiaryLight;
      border = borderLight;
    }
  }

  // ============================================================
  // DESIGN TOKENS
  // ============================================================

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusFull = 9999.0;

  // ============================================================
  // SHADOWS
  // ============================================================
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0x0A000000),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0x14000000),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ============================================================
  // LIGHT THEME
  // ============================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: primaryLight,
        surface: surfaceLight,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: _buildTextTheme(false),
      appBarTheme: _buildAppBarTheme(false),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(false),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputTheme(false),
      cardTheme: _buildCardTheme(false),
      iconTheme: const IconThemeData(color: textPrimaryLight),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      switchTheme: _buildSwitchTheme(),
      checkboxTheme: _buildCheckboxTheme(false),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLarge),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryLight,
        contentTextStyle: _getBodyStyle(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: primaryDark,
        surface: surfaceDark,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: _buildTextTheme(true),
      appBarTheme: _buildAppBarTheme(true),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(true),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputTheme(true),
      cardTheme: _buildCardTheme(true),
      iconTheme: const IconThemeData(color: textPrimaryDark),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),
      switchTheme: _buildSwitchTheme(),
      checkboxTheme: _buildCheckboxTheme(true),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLarge),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDark,
        contentTextStyle: _getBodyStyle(textPrimaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Legacy getter for compatibility
  static ThemeData get theme => lightTheme;

  // ============================================================
  // TEXT THEME
  // ============================================================
  static TextTheme _buildTextTheme(bool isDark) {
    final textColor = isDark ? textPrimaryDark : textPrimaryLight;
    final secondaryColor = isDark ? textSecondaryDark : textSecondaryLight;
    final tertiaryColor = isDark ? textTertiaryDark : textTertiaryLight;

    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -0.6,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.4,
        height: 1.3,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.2,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.1,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: tertiaryColor,
      ),
    );
  }

  static TextStyle _getBodyStyle(Color color) {
    return GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // ============================================================
  // COMPONENT THEMES
  // ============================================================
  static AppBarTheme _buildAppBarTheme(bool isDark) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      foregroundColor: isDark ? textPrimaryDark : textPrimaryLight,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? textPrimaryDark : textPrimaryLight,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(bool isDark) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? textPrimaryDark : textPrimaryLight,
        side: BorderSide(color: isDark ? borderDark : borderLight, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme(bool isDark) {
    final borderColor = isDark ? borderDark : borderLight;
    final fillColor = isDark ? surfaceDark : surfaceLight;
    final hintColor = isDark ? textTertiaryDark : textTertiaryLight;
    final labelColor = isDark ? textSecondaryDark : textSecondaryLight;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: BorderSide(
          color: isDark ? primaryDark : primaryLight,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      labelStyle: GoogleFonts.inter(color: labelColor, fontSize: 15),
      hintStyle: GoogleFonts.inter(color: hintColor, fontSize: 15),
      prefixIconColor: labelColor,
      suffixIconColor: labelColor,
      floatingLabelStyle: GoogleFonts.inter(
        color: isDark ? primaryDark : primaryLight,
        fontSize: 14,
      ),
    );
  }

  static CardThemeData _buildCardTheme(bool isDark) {
    return CardThemeData(
      elevation: 0,
      color: isDark ? surfaceDark : surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static SwitchThemeData _buildSwitchTheme() {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return const Color(0xFFD1D5DB);
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  static CheckboxThemeData _buildCheckboxTheme(bool isDark) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return isDark ? primaryDark : primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: BorderSide(color: isDark ? borderDark : borderLight, width: 1.5),
    );
  }
}
