import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system; // Default theme

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme(); // App start hotay hi saved theme load karo
  }

  // Saved theme ko load karna
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themePrefKey) ?? 'system';

    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  // Theme change karke save karna
  Future<void> setTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return; // Agar pehle se wahi theme hai to kuch na karo

    _themeMode = themeMode;
    notifyListeners(); // UI ko foran batao ke theme change ho gayi hai

    final prefs = await SharedPreferences.getInstance();
    String themeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
        break;
    }
    await prefs.setString(_themePrefKey, themeString);
  }
}