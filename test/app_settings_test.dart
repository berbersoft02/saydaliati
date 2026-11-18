import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saydaliati/core/config/app_config.dart';
import 'package:saydaliati/core/state/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSettings', () {
    test('loads default settings when preferences are empty', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = AppSettings();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(settings.isLoaded, isTrue);
      expect(settings.locale, const Locale('fr'));
      expect(settings.openOnlyFilter, isFalse);
      expect(settings.includeUnknownWhenOpenOnly, isFalse);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.searchRadiusMeters, AppConfig.searchRadiusMeters);
    });

    test('loads stored settings from preferences', () async {
      SharedPreferences.setMockInitialValues({
        'locale': 'ar',
        'open_only': true,
        'include_unknown_open': true,
        'theme_mode': 'dark',
        'search_radius_m': 10000,
      });

      final settings = AppSettings();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(settings.isLoaded, isTrue);
      expect(settings.locale, const Locale('ar'));
      expect(settings.openOnlyFilter, isTrue);
      expect(settings.includeUnknownWhenOpenOnly, isTrue);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.searchRadiusMeters, 10000);
    });

    test('falls back to default radius if stored radius is invalid', () async {
      SharedPreferences.setMockInitialValues({
        'search_radius_m': 99999, // Not in AppConfig.radiusOptionsMeters
      });

      final settings = AppSettings();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(settings.searchRadiusMeters, AppConfig.searchRadiusMeters);
    });

    test('setLocale updates state, persists, and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = AppSettings();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var notified = false;
      settings.addListener(() => notified = true);

      await settings.setLocale(const Locale('en'));

      expect(settings.locale, const Locale('en'));
      expect(notified, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale'), 'en');
    });

    test('setOpenOnlyFilter updates state, persists, and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = AppSettings();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var notified = false;
      settings.addListener(() => notified = true);

      await settings.setOpenOnlyFilter(true);

      expect(settings.openOnlyFilter, isTrue);
      expect(notified, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('open_only'), isTrue);
    });

    test('setIncludeUnknownWhenOpenOnly updates state, persists, and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = AppSettings();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var notified = false;
      settings.addListener(() => notified = true);

      await settings.setIncludeUnknownWhenOpenOnly(true);

      expect(settings.includeUnknownWhenOpenOnly, isTrue);
      expect(notified, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('include_unknown_open'), isTrue);
    });

    test('setThemeMode updates theme, persists string value, and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = AppSettings();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await settings.setThemeMode(ThemeMode.light);
      expect(settings.themeMode, ThemeMode.light);

      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');

      await settings.setThemeMode(ThemeMode.dark);
      expect(settings.themeMode, ThemeMode.dark);

      prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');

      await settings.setThemeMode(ThemeMode.system);
      expect(settings.themeMode, ThemeMode.system);

      prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'system');
    });

    test('setSearchRadiusMeters updates radius, persists, and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = AppSettings();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var notified = false;
      settings.addListener(() => notified = true);

      await settings.setSearchRadiusMeters(15000);

      expect(settings.searchRadiusMeters, 15000);
      expect(notified, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('search_radius_m'), 15000);
    });
  });
}
