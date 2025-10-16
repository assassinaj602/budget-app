import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Enhanced app theme with fallback font handling
class AppTheme {
  static String get _fontFamily {
    try {
      return GoogleFonts.poppins().fontFamily ?? _fallbackFont;
    } catch (e) {
      return _fallbackFont;
    }
  }

  static String get _fallbackFont => 'SF Pro Display';

  static TextTheme get _textTheme {
    try {
      return GoogleFonts.poppinsTextTheme();
    } catch (e) {
      return ThemeData.light().textTheme.apply(fontFamily: _fallbackFont);
    }
  }

  static TextTheme get _darkTextTheme {
    try {
      return GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    } catch (e) {
      return ThemeData.dark().textTheme.apply(fontFamily: _fallbackFont);
    }
  }
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceVariant: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    background: AppColors.background,
    onBackground: AppColors.onBackground,
    error: AppColors.danger,
    onError: Colors.white,
    errorContainer: AppColors.dangerContainer,
    onErrorContainer: AppColors.danger,
  ),
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: AppTheme._fontFamily,
  textTheme: AppTheme._textTheme.copyWith(
    displayLarge: TextStyle(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      fontSize: 32,
    ),
    displayMedium: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontSize: 28,
    ),
    displaySmall: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontSize: 24,
    ),
    headlineLarge: TextStyle(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      fontSize: 22,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontSize: 18,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      fontSize: 16,
    ),
    titleSmall: TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      fontSize: 14,
    ),
    bodyLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: AppColors.textTertiary,
      fontSize: 12,
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontSize: 14,
    ),
    labelMedium: TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      fontSize: 12,
    ),
    labelSmall: TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.textTertiary,
      fontSize: 11,
    ),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.background,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      fontFamily: AppTheme._fontFamily,
    ),
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    actionsIconTheme: IconThemeData(color: AppColors.textPrimary),
  ),
  cardTheme: CardTheme(
    elevation: 3,
    shadowColor: Colors.black.withOpacity(0.1),
    surfaceTintColor: Colors.transparent,
    margin: const EdgeInsets.all(8),
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        fontFamily: AppTheme._fontFamily,
      ),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textTertiary,
    showUnselectedLabels: true,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontFamily: AppTheme._fontFamily,
    ),
    unselectedLabelStyle: TextStyle(
      fontWeight: FontWeight.w500,
      fontFamily: AppTheme._fontFamily,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide:
          BorderSide(color: AppColors.onSurfaceVariant.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide:
          BorderSide(color: AppColors.onSurfaceVariant.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.danger),
    ),
    filled: true,
    fillColor: AppColors.surfaceVariant,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    labelStyle: TextStyle(
      color: AppColors.textSecondary,
      fontFamily: AppTheme._fontFamily,
    ),
    hintStyle: TextStyle(
      color: AppColors.textTertiary,
      fontFamily: AppTheme._fontFamily,
    ),
  ),
);

final ThemeData darkAppTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.onPrimaryContainer,
    onPrimaryContainer: AppColors.primaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.onSecondaryContainer,
    onSecondaryContainer: AppColors.secondaryContainer,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    surfaceVariant: AppColors.darkSurfaceVariant,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    background: AppColors.darkBackground,
    onBackground: AppColors.darkOnSurface,
    error: AppColors.danger,
    onError: Colors.white,
    errorContainer: AppColors.dangerContainer,
    onErrorContainer: AppColors.danger,
  ),
  fontFamily: AppTheme._fontFamily,
  textTheme: AppTheme._darkTextTheme.copyWith(
    displayLarge: TextStyle(
      fontWeight: FontWeight.w700,
      color: AppColors.darkOnSurface,
      fontSize: 32,
    ),
    displayMedium: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.darkOnSurface,
      fontSize: 28,
    ),
    displaySmall: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.darkOnSurface,
      fontSize: 24,
    ),
    headlineLarge: TextStyle(
      fontWeight: FontWeight.w700,
      color: AppColors.darkOnSurface,
      fontSize: 22,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.darkOnSurface,
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.darkOnSurface,
      fontSize: 18,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.darkOnSurface,
      fontSize: 16,
    ),
    titleSmall: TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.darkOnSurfaceVariant,
      fontSize: 14,
    ),
    bodyLarge: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: AppColors.darkOnSurfaceVariant,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: AppColors.darkOnSurfaceVariant.withOpacity(0.7),
      fontSize: 12,
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.darkOnSurface,
      fontSize: 14,
    ),
    labelMedium: TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.darkOnSurfaceVariant,
      fontSize: 12,
    ),
    labelSmall: TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.darkOnSurfaceVariant.withOpacity(0.7),
      fontSize: 11,
    ),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.darkSurface,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.darkOnSurface,
      fontFamily: AppTheme._fontFamily,
    ),
    iconTheme: IconThemeData(color: AppColors.darkOnSurface),
    actionsIconTheme: IconThemeData(color: AppColors.darkOnSurface),
  ),
  cardTheme: CardTheme(
    elevation: 3,
    shadowColor: Colors.black.withOpacity(0.3),
    surfaceTintColor: Colors.transparent,
    margin: const EdgeInsets.all(8),
    color: AppColors.darkSurfaceVariant,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        fontFamily: AppTheme._fontFamily,
      ),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSurfaceVariant,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.darkOnSurfaceVariant.withOpacity(0.6),
    showUnselectedLabels: true,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontFamily: AppTheme._fontFamily,
    ),
    unselectedLabelStyle: TextStyle(
      fontWeight: FontWeight.w500,
      fontFamily: AppTheme._fontFamily,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide:
          BorderSide(color: AppColors.darkOnSurfaceVariant.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide:
          BorderSide(color: AppColors.darkOnSurfaceVariant.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.danger),
    ),
    filled: true,
    fillColor: AppColors.darkSurfaceVariant,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    labelStyle: TextStyle(
      color: AppColors.darkOnSurfaceVariant,
      fontFamily: AppTheme._fontFamily,
    ),
    hintStyle: TextStyle(
      color: AppColors.darkOnSurfaceVariant.withOpacity(0.6),
      fontFamily: AppTheme._fontFamily,
    ),
  ),
);

// Enhanced color palette with Material Design 3 support
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1E1B3E);

  // Secondary colors
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryContainer = Color(0xFFD1FAE5);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF064E3B);

  // Surface colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF64748B);

  // Background colors
  static const Color background = Color(0xFFFEFEFE);
  static const Color onBackground = Color(0xFF0F172A);

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // Income/Expense specific colors
  static const Color income = Color(0xFF10B981);
  static const Color incomeLight = Color(0xFFECFDF5);
  static const Color expense = Color(0xFFEF4444);
  static const Color expenseLight = Color(0xFFFEF2F2);

  // Dark theme colors
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkSurfaceVariant = Color(0xFF1E293B);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkOnSurfaceVariant = Color(0xFFCBD5E1);
  static const Color darkBackground = Color(0xFF020617);
}
