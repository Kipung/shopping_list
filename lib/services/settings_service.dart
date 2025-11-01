import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const _darkKey = 'theme_is_dark';
  static const _seedKey = 'theme_seed_value';
  static const _blendKey = 'theme_seed_blend';

  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  // Seed color stored as ARGB integer
  int _seedValue = 0xFF93E5FA; // default: ARGB(255,147,229,250)
  int get seedValue => _seedValue;
  Color get seedColor => Color(_seedValue);

  // Blend amount: 0.0 = original color, 1.0 = fully white (muted)
  double _blendAmount = 0.0;
  double get blendAmount => _blendAmount;

  // Returns the seed color blended toward white by [_blendAmount]
  Color get adjustedSeedColor => Color.lerp(seedColor, Colors.white, _blendAmount) ?? seedColor;
  
  
  SettingsService();

  // Initialize settings from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_darkKey) ?? false;
    _seedValue = prefs.getInt(_seedKey) ?? _seedValue;
    _blendAmount = prefs.getDouble(_blendKey) ?? _blendAmount;
    notifyListeners();
  }

// Update dark mode setting
  Future<void> setDark(bool value) async {
    _isDark = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
    notifyListeners();
  }

  // Update seed color setting
  Future<void> setSeed(int value) async {
    _seedValue = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedKey, value);
    notifyListeners();
  }

  Future<void> setBlend(double value) async {
    _blendAmount = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_blendKey, _blendAmount);
    notifyListeners();
  }
}
