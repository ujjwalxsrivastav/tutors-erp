import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Expert Tutors Academy Design System
/// Deep green + gold palette — sophisticated, growth-oriented
class AppTheme {
  AppTheme._();

  // ─── Brand Colors ────────────────────────────────────────────
  // Deep green + gold palette
  static const Color primaryGreen = Color(0xFF1B5E3B);
  static const Color primaryGreenLight = Color(0xFF2E7D52);
  static const Color primaryGreenDark = Color(0xFF0D3B23);
  static const Color accentGold = Color(0xFFD4A843);
  static const Color accentGoldLight = Color(0xFFE8C872);
  static const Color accentGoldDark = Color(0xFFB8922E);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color backgroundLight = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);
  static const Color border = Color(0xFFE2E5EA);
  static const Color borderLight = Color(0xFFF0F1F3);
  static const Color textPrimary = Color(0xFF1A1D23);
  static const Color textSecondary = Color(0xFF5A6170);
  static const Color textTertiary = Color(0xFF8E95A2);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnGold = Color(0xFF1A1D23);

  // Semantic
  static const Color success = Color(0xFF22A06B);
  static const Color successLight = Color(0xFFDFFBEF);
  static const Color warning = Color(0xFFE8A230);
  static const Color warningLight = Color(0xFFFFF4E0);
  static const Color error = Color(0xFFDE350B);
  static const Color errorLight = Color(0xFFFFEDE6);
  static const Color info = Color(0xFF0065FF);
  static const Color infoLight = Color(0xFFE6F0FF);

  // Status colors
  static const Color statusNew = Color(0xFF0065FF);
  static const Color statusMatching = Color(0xFF6554C0);
  static const Color statusMatched = Color(0xFF00B8D9);
  static const Color statusAssigned = Color(0xFFE8A230);
  static const Color statusConverted = Color(0xFF22A06B);
  static const Color statusRejected = Color(0xFFDE350B);
  static const Color statusCancelled = Color(0xFF8E95A2);

  // ─── Spacing ─────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  static const double spacingXxxl = 64.0;

  // ─── Border Radius ──────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ─── Elevation ──────────────────────────────────────────────
  static const List<BoxShadow> elevationSm = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevationMd = [
    BoxShadow(
      color: Color(0x0C000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevationLg = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  // ─── Typography ─────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.15,
        color: textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        height: 1.2,
        color: textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
        color: textPrimary,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
        color: textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
        color: textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textTertiary,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.4,
        color: textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
        color: textTertiary,
      );

  // ─── ThemeData ──────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        onPrimary: textOnPrimary,
        primaryContainer: primaryGreenLight,
        secondary: accentGold,
        onSecondary: textOnGold,
        secondaryContainer: accentGoldLight,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: white,
        outline: border,
        outlineVariant: borderLight,
      ),
      textTheme: TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: surface,
        foregroundColor: textPrimary,
        titleTextStyle: headlineSmall,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: labelLarge.copyWith(color: textOnPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          side: BorderSide(color: primaryGreen),
          textStyle: labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: error, width: 2),
        ),
        hintStyle: bodyMedium.copyWith(color: textTertiary),
        labelStyle: bodyMedium,
        errorStyle: bodySmall.copyWith(color: error),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primaryGreen.withValues(alpha: 0.12),
        labelStyle: labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        elevation: 8,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        elevation: 8,
        backgroundColor: surface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryGreen,
        unselectedLabelColor: textTertiary,
        indicatorColor: primaryGreen,
        labelStyle: labelLarge,
        unselectedLabelStyle: labelLarge.copyWith(fontWeight: FontWeight.w400),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: const IconThemeData(color: primaryGreen),
        unselectedIconTheme: IconThemeData(color: textTertiary),
        selectedLabelTextStyle: labelMedium.copyWith(color: primaryGreen),
        unselectedLabelTextStyle: labelMedium,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
      ),
    );
  }

  // ─── Status Color Helper ────────────────────────────────────
  static Color getLeadStatusColor(String status) {
    switch (status) {
      case 'NEW':
        return statusNew;
      case 'MATCHING':
        return statusMatching;
      case 'MATCHED':
        return statusMatched;
      case 'TUTOR_SUGGESTED':
      case 'ASSIGNED':
      case 'CONTACTED':
        return statusAssigned;
      case 'DEMO_SCHEDULED':
        return info;
      case 'CONVERTED':
        return statusConverted;
      case 'REJECTED':
      case 'LOST':
        return statusRejected;
      case 'CANCELLED':
      case 'NO_RESPONSE':
        return statusCancelled;
      default:
        return textTertiary;
    }
  }

  static Color getVerificationColor(String status) {
    switch (status) {
      case 'VERIFIED':
        return success;
      case 'PENDING':
        return warning;
      case 'REJECTED':
        return error;
      case 'SUSPENDED':
        return statusCancelled;
      default:
        return textTertiary;
    }
  }
}
