import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

abstract class ThemeStorage {
  Future<String?> getTheme();
  Future<void> saveTheme(String theme);
}

ThemeStorage createThemeStorage() {
  // Кроссплатформенная реализация
  if (kIsWeb) return WebThemeStorage();
  return MobileThemeStorage();
}

class WebThemeStorage implements ThemeStorage {
  @override
  Future<String?> getTheme() async => html.window.localStorage['theme'];

  @override
  Future<void> saveTheme(String theme) async {
    html.window.localStorage['theme'] = theme;
  }
}

class MobileThemeStorage implements ThemeStorage {
  @override
  Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme');
  }

  @override
  Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
  }
}