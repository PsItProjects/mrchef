import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  static ThemeService get instance => Get.find<ThemeService>();
  
  final _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;
  
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  
  static const String _themeModeKey = 'theme_mode';
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
      _themeMode.value = ThemeMode.values[themeModeIndex];
      _updateDarkModeStatus();
    } catch (e) {
      print('Error loading theme mode: $e');
      _themeMode.value = ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
      _themeMode.value = mode;
      _updateDarkModeStatus();
      Get.changeThemeMode(mode);
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }
  
  void _updateDarkModeStatus() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        _isDarkMode.value = false;
        break;
      case ThemeMode.dark:
        _isDarkMode.value = true;
        break;
      case ThemeMode.system:
        _isDarkMode.value = Get.isPlatformDarkMode;
        break;
    }
  }
  
  Future<void> toggleTheme() async {
    final newMode = _isDarkMode.value ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }
  
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }
  
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
}
