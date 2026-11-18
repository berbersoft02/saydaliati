import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:saydaliati/core/services/favorites_service.dart';
import 'package:saydaliati/models/pharmacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pharmacyA = Pharmacy(
    id: '101',
    name: 'Alpha Pharmacy',
    address: '123 Alpha St',
    location: LatLng(36.75, 3.05),
  );

  const pharmacyB = Pharmacy(
    id: '102',
    name: 'Beta Pharmacy',
    address: '456 Beta Ave',
    location: LatLng(36.76, 3.06),
  );

  group('FavoritesService', () {
    test('initial state is not loaded', () {
      final service = FavoritesService();
      expect(service.isLoaded, isFalse);
      expect(service.favorites, isEmpty);
      expect(service.recentSearches, isEmpty);
    });

    test('loads empty favorites and searches from empty preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final service = FavoritesService();

      var notified = false;
      service.addListener(() => notified = true);

      await service.load();

      expect(service.isLoaded, isTrue);
      expect(service.favorites, isEmpty);
      expect(service.recentSearches, isEmpty);
      expect(notified, isTrue);
    });

    test('loads existing favorites and recent searches from preferences', () async {
      final storedFavorites = [pharmacyB.toJson(), pharmacyA.toJson()];
      SharedPreferences.setMockInitialValues({
        'favorites_v1': json.encode(storedFavorites),
        'recent_searches_v1': ['Didouche', 'Bab El Oued'],
      });

      final service = FavoritesService();
      await service.load();

      expect(service.isLoaded, isTrue);
      expect(service.favorites.length, 2);
      // Alphabetical sorting check: Alpha before Beta
      expect(service.favorites.first.id, '101');
      expect(service.favorites.last.id, '102');
      expect(service.isFavorite('101'), isTrue);
      expect(service.isFavorite('999'), isFalse);
      expect(service.recentSearches, ['Didouche', 'Bab El Oued']);
    });

    test('handles corrupted favorites JSON gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'favorites_v1': 'not-valid-json',
      });

      final service = FavoritesService();
      await service.load();

      expect(service.isLoaded, isTrue);
      expect(service.favorites, isEmpty);
    });

    test('toggle adds and removes favorites, persists, and notifies', () async {
      SharedPreferences.setMockInitialValues({});
      final service = FavoritesService();
      await service.load();

      var notifyCount = 0;
      service.addListener(() => notifyCount++);

      // 1. Add pharmacyA
      await service.toggle(pharmacyA);
      expect(service.isFavorite('101'), isTrue);
      expect(service.favorites.length, 1);
      expect(notifyCount, 1);

      var prefs = await SharedPreferences.getInstance();
      var raw = prefs.getString('favorites_v1');
      expect(raw, isNotNull);
      expect(json.decode(raw!).length, 1);

      // 2. Add pharmacyB
      await service.toggle(pharmacyB);
      expect(service.isFavorite('102'), isTrue);
      expect(service.favorites.length, 2);
      expect(notifyCount, 2);

      // 3. Remove pharmacyA via toggle
      await service.toggle(pharmacyA);
      expect(service.isFavorite('101'), isFalse);
      expect(service.favorites.length, 1);
      expect(service.favorites.first.id, '102');
      expect(notifyCount, 3);
    });

    test('remove removes pharmacy by id, persists, and notifies', () async {
      SharedPreferences.setMockInitialValues({});
      final service = FavoritesService();
      await service.load();

      await service.toggle(pharmacyA);
      expect(service.isFavorite('101'), isTrue);

      await service.remove('101');
      expect(service.isFavorite('101'), isFalse);
      expect(service.favorites, isEmpty);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('favorites_v1');
      expect(json.decode(raw!), isEmpty);
    });

    test('addRecentSearch trims, deduplicates, and limits to 12 items', () async {
      SharedPreferences.setMockInitialValues({});
      final service = FavoritesService();
      await service.load();

      // Empty or whitespace strings are ignored
      await service.addRecentSearch('   ');
      expect(service.recentSearches, isEmpty);

      // Add searches
      await service.addRecentSearch('Algiers');
      await service.addRecentSearch('Oran');
      expect(service.recentSearches, ['Oran', 'Algiers']);

      // Deduplication (case-insensitive re-ordering to front)
      await service.addRecentSearch('algiers');
      expect(service.recentSearches, ['algiers', 'Oran']);

      // Max capacity capping at 12
      for (var i = 1; i <= 15; i++) {
        await service.addRecentSearch('City $i');
      }
      expect(service.recentSearches.length, 12);
      expect(service.recentSearches.first, 'City 15');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('recent_searches_v1')?.length, 12);
    });

    test('clearRecent removes all searches, persists, and notifies', () async {
      SharedPreferences.setMockInitialValues({});
      final service = FavoritesService();
      await service.load();

      await service.addRecentSearch('Annaba');
      expect(service.recentSearches.isNotEmpty, isTrue);

      await service.clearRecent();
      expect(service.recentSearches, isEmpty);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('recent_searches_v1'), isNull);
    });
  });
}
