import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(Brightness platformBrightness) {
    if (_themeMode == ThemeMode.system) {
      // If system mode, toggle to opposite of current system setting
      _themeMode = platformBrightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    } else {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
