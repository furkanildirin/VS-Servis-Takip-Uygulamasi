import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings with ChangeNotifier {
  bool _isDarkMode = false;
  String _fontFamily = 'Roboto';
  double _fontSize = 14.0;

  bool get isDarkMode => _isDarkMode;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;

  Settings() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontFamily = prefs.getString('fontFamily') ?? 'Roboto';
    _fontSize = prefs.getDouble('fontSize') ?? 14.0;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setFontFamily(String fontFamily) async {
    _fontFamily = fontFamily;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', _fontFamily);
    notifyListeners();
  }

  Future<void> setFontSize(double fontSize) async {
    _fontSize = fontSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
    notifyListeners();
  }

  ThemeData getThemeData() {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: _fontSize,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: _fontSize,
        ),
      ),
      useMaterial3: true,
    );
  }
}
