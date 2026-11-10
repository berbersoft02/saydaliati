import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Persists user preferences and broadcasts changes.
class AppSettings extends ChangeNotifier {
  static const _kLocale = 'locale';
  static const _kOpenOnly = 'open_only';
  static const _kIncludeUnknown = 'include_unknown_open';
  static const _kThemeMode = 'theme_mode';
  static const _kRadius = 'search_radius_m';

  Locale _locale = const Locale('fr');
  bool _openOnlyFilter = false;
  bool _includeUnknownWhenOpenOnly = false;
  ThemeMode _themeMode = ThemeMode.system;
  int _searchRadiusMeters = AppConfig.searchRadiusMeters;
  bool _loaded = false;

  Locale get locale => _locale;
  bool get openOnlyFilter => _openOnlyFilter;
  bool get includeUnknownWhenOpenOnly => _includeUnknownWhenOpenOnly;
  ThemeMode get themeMode => _themeMode;
  int get searchRadiusMeters => _searchRadiusMeters;
  bool get isLoaded => _loaded;

  AppSettings() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocale);
    if (code != null) {
      _locale = Locale(code);
    }
    _openOnlyFilter = prefs.getBool(_kOpenOnly) ?? false;
    _includeUnknownWhenOpenOnly = prefs.getBool(_kIncludeUnknown) ?? false;
    final theme = prefs.getString(_kThemeMode);
    _themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _searchRadiusMeters =
        prefs.getInt(_kRadius) ?? AppConfig.searchRadiusMeters;
    if (!AppConfig.radiusOptionsMeters.contains(_searchRadiusMeters)) {
      _searchRadiusMeters = AppConfig.searchRadiusMeters;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, locale.languageCode);
  }

  Future<void> setOpenOnlyFilter(bool value) async {
    _openOnlyFilter = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOpenOnly, value);
  }

  Future<void> setIncludeUnknownWhenOpenOnly(bool value) async {
    _includeUnknownWhenOpenOnly = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIncludeUnknown, value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_kThemeMode, value);
  }

  Future<void> setSearchRadiusMeters(int meters) async {
    _searchRadiusMeters = meters;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRadius, meters);
  }
}
