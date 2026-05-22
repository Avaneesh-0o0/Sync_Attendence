import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the educational attendance application.
/// Implements Minimal Cyberpunk Theme with vibrant glowing effects and modern aesthetics.
class AppTheme {
  AppTheme._();

  // Minimal Cyberpunk Theme - Colors
  static const Color primaryLight = Color(0xFF00F5FF); // Electric Cyan
  static const Color primaryVariantLight = Color(0xFF38BDF8); // Icy Blue
  static const Color secondaryLight = Color(0xFF7C3AED); // Neon Purple
  static const Color secondaryVariantLight = Color(0xFF6D28D9); // Darker Purple
  static const Color backgroundLight = Color(0xFF0A0F1F); // Deep Navy Black
  static const Color surfaceLight = Color(0xFF111827); // Dark Slate
  static const Color errorLight = Color(0xFFEF4444); // Red
  static const Color warningLight = Color(0xFFF59E0B); // Amber
  static const Color infoLight = Color(0xFF38BDF8); // Icy Blue
  static const Color successLight = Color(0xFF10B981); // Emerald
  static const Color onPrimaryLight = Color(0xFF0A0F1F); // Contrast on Electric Cyan
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color onSurfaceLight = Color(0xFFF1F5F9); // Slate 100
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color accentPink = Color(0xFFEC4899); // Pink
  static const Color accentPurple = Color(0xFF7C3AED); // Neon Purple
  static const Color accentOrange = Color(0xFFF97316); // Orange

  // Premium Modern Dark Theme - Dark Mode Colors (same as Cyberpunk)
  static const Color primaryDark = primaryLight;
  static const Color primaryVariantDark = primaryVariantLight;
  static const Color secondaryDark = secondaryLight;
  static const Color secondaryVariantDark = secondaryVariantLight;
  static const Color backgroundDark = backgroundLight;
  static const Color surfaceDark = surfaceLight;
  static const Color errorDark = errorLight;
  static const Color warningDark = warningLight;
  static const Color infoDark = infoLight;
  static const Color successDark = successLight;
  static const Color onPrimaryDark = onPrimaryLight;
  static const Color onSecondaryDark = onSecondaryLight;
  static const Color onBackgroundDark = onBackgroundLight;
  static const Color onSurfaceDark = onSurfaceLight;
  static const Color onErrorDark = onErrorLight;

  // Card and dialog colors
  static const Color cardLight = surfaceLight;
  static const Color cardDark = surfaceDark;
  static const Color dialogLight = surfaceLight;
  static const Color dialogDark = surfaceDark;

  // Shadow colors
  static const Color shadowLight = Color(0x66000000);
  static const Color shadowDark = Color(0x66000000);

  // Divider and border colors
  static const Color dividerLight = Color(0xFF1F2937); // Dark Slate border
  static const Color dividerDark = Color(0xFF1F2937);

  // Text colors
  static const Color textHighEmphasisLight = Color(0xFFF8FAFC);
  static const Color textMediumEmphasisLight = Color(0xFF9CA3AF); // Gray 400
  static const Color textDisabledLight = Color(0xFF4B5563); // Gray 600

  static const Color textHighEmphasisDark = Color(0xFFF8FAFC);
  static const Color textMediumEmphasisDark = Color(0xFF9CA3AF);
  static const Color textDisabledDark = Color(0xFF4B5563);

  /// Cyberpunk theme optimized for modern aesthetics
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
      onTertiary: onSecondaryLight,
      tertiaryContainer: accentPink,
      onTertiaryContainer: onSecondaryLight,
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
      scrim: Color(0xAA000000),
      inverseSurface: Color(0xFFFFFFFF),
      onInverseSurface: Color(0xFF0A0F1F),
      inversePrimary: Color(0xFF0A0F1F),
      surfaceTint: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    dividerColor: dividerLight,
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.transparent,
      foregroundColor: primaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.orbitron(
        fontSize: 18,
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
        side: BorderSide(color: primaryLight.withValues(alpha: 0.15), width: 1.5),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textMediumEmphasisLight,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: onPrimaryLight,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: primaryLight.withValues(alpha: 0.3), width: 1.5),
      ),
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
          side: BorderSide(color: primaryLight.withValues(alpha: 0.3), width: 1.5),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        shadowColor: primaryLight.withValues(alpha: 0.4),
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
        textStyle: GoogleFonts.inter(
          fontSize: 13,
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
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationThemeData(
      fillColor: backgroundLight,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: primaryLight.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: primaryLight.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryLight, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorLight, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorLight, width: 2.0),
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
      side: BorderSide(color: primaryLight.withValues(alpha: 0.3), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: dialogLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: primaryLight.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      titleTextStyle: GoogleFonts.inter(
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
        side: BorderSide(color: primaryLight.withValues(alpha: 0.3), width: 1.5),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textMediumEmphasisLight,
      indicatorColor: primaryLight,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      textStyle: GoogleFonts.inter(color: textHighEmphasisLight, fontSize: 12),
    ),
    dividerTheme: DividerThemeData(
      color: dividerLight.withValues(alpha: 0.5),
      thickness: 1.5,
      space: 1,
    ),
    iconTheme: IconThemeData(color: primaryLight, size: 24),
  );

  /// Dark theme (same as light for neon effect)
  static ThemeData darkTheme = lightTheme;

  /// Build text theme with cyberpunk aesthetics
  static TextTheme _buildTextTheme({required bool isLight}) {
    final baseColor = isLight ? textHighEmphasisLight : textHighEmphasisDark;
    final mediumColor = isLight
        ? textMediumEmphasisLight
        : textMediumEmphasisDark;

    return TextTheme(
      displayLarge: GoogleFonts.orbitron(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: primaryLight,
        letterSpacing: 1.5,
      ),
      displayMedium: GoogleFonts.orbitron(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: primaryLight,
        letterSpacing: 1.2,
      ),
      displaySmall: GoogleFonts.orbitron(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: primaryLight,
        letterSpacing: 1.0,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 0.8,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      headlineSmall: GoogleFonts.inter(
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
