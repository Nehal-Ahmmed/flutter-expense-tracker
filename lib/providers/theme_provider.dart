import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [ThemeProvider]
/// Manages the theme state of the application.
///
/// Use `Provider.of<ThemeProvider>(context)` to access.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Loads the saved theme from SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode');
    if (themeString != null) {
      if (themeString == 'ThemeMode.light') {
        _themeMode = ThemeMode.light;
      } else if (themeString == 'ThemeMode.dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }

  /// Sets the theme and saves preference
  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
  }

  /// Toggles between Light and Dark mode
  void toggleTheme(bool isDark) {
    setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
