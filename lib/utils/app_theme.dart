import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00ADB5);
  static const Color accentColor = Color(0xFFFFD369);
  static const Color darkBackground = Color(0xFF121212);
  static const Color lightBackground = Color(0xFFF5F5F5);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
    ),
    scaffoldBackgroundColor: lightBackground,
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
    ),
    scaffoldBackgroundColor: darkBackground,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
