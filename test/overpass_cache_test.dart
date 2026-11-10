import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:saydaliati/core/services/overpass_cache.dart';
import 'package:saydaliati/models/pharmacy.dart';

void main() {
  group('OverpassCache', () {
    test('stores and returns pharmacies', () {
      final cache = OverpassCache(ttl: const Duration(minutes: 5));
      final key = OverpassCache.nearbyKey(
        latitude: 36.75,
        longitude: 3.05,
        radiusMeters: 5000,
      );
      final list = [
        Pharmacy(
          id: '1',
          name: 'A',
          address: '',
          location: const LatLng(36.75, 3.05),
        ),
      ];
      expect(cache.get(key), isNull);
      cache.put(key, list);
      final hit = cache.get(key);
      expect(hit, isNotNull);
      expect(hit!.length, 1);
      expect(hit.first.name, 'A');
    });

    test('nearby keys round so tiny jitter matches', () {
      final a = OverpassCache.nearbyKey(
        latitude: 36.75381,
        longitude: 3.05882,
        radiusMeters: 5000,
      );
      final b = OverpassCache.nearbyKey(
        latitude: 36.75389,
        longitude: 3.05885,
        radiusMeters: 5000,
      );
      expect(a, b);
    });

    test('expired entries are dropped', () async {
      final cache = OverpassCache(ttl: const Duration(milliseconds: 30));
      const key = 'k';
      cache.put(key, const []);
      expect(cache.get(key), isNotNull);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cache.get(key), isNull);
    });
  });
}
