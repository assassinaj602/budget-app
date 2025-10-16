import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final String key = "theme";
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadFromPrefs();
  }

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF00ADB5),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00ADB5),
          secondary: Color(0xFFFFD369),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: GoogleFonts.poppinsTextTheme(),
      );

  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00ADB5),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00ADB5),
          secondary: Color(0xFFFFD369),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      );

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _themeMode =
        (_prefs.getBool(key) ?? false) ? ThemeMode.dark : ThemeMode.light;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setBool(key, _themeMode == ThemeMode.dark);
  }
}
