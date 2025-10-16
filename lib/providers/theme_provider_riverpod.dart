import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String key = "theme";
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  ThemeNotifier() : super(ThemeMode.light) {
    _loadFromPrefs();
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
  }

  Future<void> _loadFromPrefs() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    final isDark = _prefs.getBool(key) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    _isInitialized = true;
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setBool(key, state == ThemeMode.dark);
  }
}
