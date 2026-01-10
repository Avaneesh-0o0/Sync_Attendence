import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the educational attendance application.
/// Implements Neon UI Theme with vibrant glowing effects and modern aesthetics.
class AppTheme {
  AppTheme._();

  // Neon Theme Palette - Light Theme Colors
  static const Color primaryLight = Color(0xFF00E5FF); // Neon cyan
  static const Color primaryVariantLight = Color(0xFF00B8D4);
  static const Color secondaryLight = Color(0xFF76FF03); // Neon green
  static const Color secondaryVariantLight = Color(0xFF64DD17);
  static const Color backgroundLight = Color(0xFF0A0E27); // Dark blue-black
  static const Color surfaceLight = Color(0xFF1A1F3A); // Dark surface
  static const Color errorLight = Color(0xFFFF1744); // Neon red
  static const Color warningLight = Color(0xFFFFEA00); // Neon yellow
  static const Color infoLight = Color(0xFF00E5FF); // Neon cyan
  static const Color successLight = Color(0xFF76FF03); // Neon green
  static const Color onPrimaryLight = Color(0xFF0A0E27);
  static const Color onSecondaryLight = Color(0xFF0A0E27);
  static const Color onBackgroundLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFFE0E0E0);
  static const Color onErrorLight = Color(0xFF0A0E27);
  static const Color accentPink = Color(0xFFFF006E); // Neon pink
  static const Color accentPurple = Color(0xFFD500F9); // Neon purple
  static const Color accentOrange = Color(0xFFFF6D00); // Neon orange

  // Neon Theme Palette - Dark Theme Colors (same as light for neon effect)
  static const Color primaryDark = Color(0xFF00E5FF);
  static const Color primaryVariantDark = Color(0xFF00B8D4);
  static const Color secondaryDark = Color(0xFF76FF03);
  static const Color secondaryVariantDark = Color(0xFF64DD17);
  static const Color backgroundDark = Color(0xFF0A0E27);
  static const Color surfaceDark = Color(0xFF1A1F3A);
  static const Color errorDark = Color(0xFFFF1744);
  static const Color warningDark = Color(0xFFFFEA00);
  static const Color infoDark = Color(0xFF00E5FF);
  static const Color successDark = Color(0xFF76FF03);
  static const Color onPrimaryDark = Color(0xFF0A0E27);
  static const Color onSecondaryDark = Color(0xFF0A0E27);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
  static const Color onErrorDark = Color(0xFF0A0E27);

  // Card and dialog colors
  static const Color cardLight = Color(0xFF1A1F3A);
  static const Color cardDark = Color(0xFF1A1F3A);
  static const Color dialogLight = Color(0xFF1A1F3A);
  static const Color dialogDark = Color(0xFF1A1F3A);

  // Shadow colors - Neon glow effects
  static const Color shadowLight = Color(0x4000E5FF);
  static const Color shadowDark = Color(0x4000E5FF);

  // Divider and border colors
  static const Color dividerLight = Color(0xFF00E5FF);
  static const Color dividerDark = Color(0xFF00E5FF);

  // Text colors with neon aesthetics
  static const Color textHighEmphasisLight = Color(0xFFFFFFFF);
  static const Color textMediumEmphasisLight = Color(0xFFB0B0B0);
  static const Color textDisabledLight = Color(0xFF6E6E6E);

  static const Color textHighEmphasisDark = Color(0xFFFFFFFF);
  static const Color textMediumEmphasisDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF6E6E6E);

  /// Neon theme optimized for modern aesthetics
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: primaryVariantLight,
      onPrimaryContainer: onPrimaryLight,
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: secondaryVariantLight,
      onSecondaryContainer: onSecondaryLight,
      tertiary: accentPurple,
      onTertiary: onPrimaryLight,
      tertiaryContainer: accentPink,
      onTertiaryContainer: onPrimaryLight,
      error: errorLight,
      onError: onErrorLight,
      errorContainer: Color(0xFF4D0010),
      onErrorContainer: errorLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: textMediumEmphasisLight,
      outline: dividerLight,
      outlineVariant: primaryVariantLight,
      shadow: shadowLight,
      scrim: Color(0x80000000),
      inverseSurface: Color(0xFFFFFFFF),
      onInverseSurface: Color(0xFF0A0E27),
      inversePrimary: Color(0xFF0A0E27),
      surfaceTint: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    dividerColor: dividerLight,
    appBarTheme: AppBarThemeData(
      backgroundColor: surfaceLight,
      foregroundColor: primaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.rajdhani(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primaryLight,
        letterSpacing: 2.0,
      ),
      iconTheme: IconThemeData(color: primaryLight, size: 24),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: primaryLight.withValues(alpha: 0.3), width: 1),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textMediumEmphasisLight,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.rajdhani(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.rajdhani(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: secondaryLight,
      foregroundColor: onSecondaryLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryLight,
        backgroundColor: primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 0,
        minimumSize: Size(88, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        shadowColor: primaryLight.withValues(alpha: 0.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: Size(88, 48),
        side: BorderSide(color: primaryLight, width: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: Size(64, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationThemeData(
      fillColor: surfaceLight,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: primaryLight.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: primaryLight.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryLight, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorLight, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorLight, width: 2.5),
      ),
      labelStyle: GoogleFonts.inter(
        color: textMediumEmphasisLight,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabledLight,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.inter(
        color: errorLight,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Color(0xFF6E6E6E);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.5);
        }
        return Color(0xFF2D2D2D);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimaryLight),
      side: BorderSide(color: primaryLight, width: 2),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textMediumEmphasisLight;
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryLight,
      inactiveTrackColor: primaryLight.withValues(alpha: 0.3),
      thumbColor: primaryLight,
      overlayColor: primaryLight.withValues(alpha: 0.2),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: primaryLight.withValues(alpha: 0.3),
      circularTrackColor: primaryLight.withValues(alpha: 0.3),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight,
      selectedColor: primaryLight.withValues(alpha: 0.2),
      disabledColor: Color(0xFF2D2D2D),
      labelStyle: GoogleFonts.inter(color: textHighEmphasisLight, fontSize: 14),
      secondaryLabelStyle: GoogleFonts.inter(
        color: primaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      side: BorderSide(color: primaryLight.withValues(alpha: 0.5), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: dialogLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: primaryLight.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      titleTextStyle: GoogleFonts.rajdhani(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primaryLight,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 16,
        color: textHighEmphasisLight,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceLight,
      contentTextStyle: GoogleFonts.inter(
        color: textHighEmphasisLight,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryLight.withValues(alpha: 0.5), width: 1),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textMediumEmphasisLight,
      indicatorColor: primaryLight,
      labelStyle: GoogleFonts.rajdhani(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.rajdhani(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryLight.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      textStyle: GoogleFonts.inter(color: textHighEmphasisLight, fontSize: 12),
    ),
    dividerTheme: DividerThemeData(
      color: dividerLight.withValues(alpha: 0.3),
      thickness: 1,
      space: 1,
    ),
    iconTheme: IconThemeData(color: primaryLight, size: 24),
  );

  /// Dark theme (same as light for neon effect)
  static ThemeData darkTheme = lightTheme;

  /// Build text theme with neon aesthetics
  static TextTheme _buildTextTheme({required bool isLight}) {
    final baseColor = isLight ? textHighEmphasisLight : textHighEmphasisDark;
    final mediumColor = isLight
        ? textMediumEmphasisLight
        : textMediumEmphasisDark;

    return TextTheme(
      displayLarge: GoogleFonts.rajdhani(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: primaryLight,
        letterSpacing: 1.5,
      ),
      displayMedium: GoogleFonts.rajdhani(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: primaryLight,
        letterSpacing: 1.2,
      ),
      displaySmall: GoogleFonts.rajdhani(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: primaryLight,
        letterSpacing: 1.0,
      ),
      headlineLarge: GoogleFonts.rajdhani(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 0.8,
      ),
      headlineMedium: GoogleFonts.rajdhani(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      headlineSmall: GoogleFonts.rajdhani(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.3,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.15,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mediumColor,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 1.25,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 1.0,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: mediumColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
