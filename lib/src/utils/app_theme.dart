import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:landingpage/src/utils/colors.dart';

class AppTheme extends ChangeNotifier with WidgetsBindingObserver {
  AppTheme._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  static final AppTheme instance = AppTheme._internal();

  static const _kThemeModeKey = 'app_theme_mode'; // 'light' | 'dark' | 'system'
  static const _kAccentColorKey = 'app_accent_color'; // ARGB int
  static const _kShowAnimationsKey = 'app_show_animations';

  ThemeMode _themeMode = ThemeMode.dark;
  Color _accentColor = AppColors.primaryPurple;
  bool _showAnimations = true;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  bool get showAnimations => _showAnimations;

  Duration get animDuration =>
      _showAnimations ? const Duration(milliseconds: 260) : Duration.zero;

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();

    final storedMode = prefs.getString(_kThemeModeKey);
    _themeMode = switch (storedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };

    final storedColor = prefs.getInt(_kAccentColorKey);
    if (storedColor != null) _accentColor = Color(storedColor);

    _showAnimations = prefs.getBool(_kShowAnimationsKey) ?? true;

    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
  }

  Future<void> toggleDark() =>
      setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAccentColorKey, color.toARGB32());
  }

  Future<void> setShowAnimations(bool value) async {
    _showAnimations = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowAnimationsKey, value);
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) notifyListeners();
  }
}
