import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saydaliati/core/services/overpass_cache.dart';
import 'package:saydaliati/core/services/overpass_service.dart';
import 'package:saydaliati/models/pharmacy.dart';

void main() {
  const sampleElements = [
    {
      'type': 'node',
      'id': 1001,
      'lat': 36.7540,
      'lon': 3.0590,
      'tags': {
        'name': 'Pharmacie Centrale',
        'addr:street': 'Rue Didouche Mourad',
        'addr:city': 'Alger',
        'opening_hours': '24/7',
        'phone': '+21321000000',
      },
    },
    {
      'type': 'node',
      'id': 1002,
      'lat': 36.7590,
      'lon': 3.0650,
      'tags': {
        'name': 'Pharmacie El Afia',
        'addr:street': 'Boulevard Colonel Amirouche',
        'opening_hours': 'Mo-Fr 08:00-18:00',
      },
    },
    {
      'type': 'node',
      'id': 1003,
      'lat': 36.7510,
      'lon': 3.0520,
      'tags': {
        'name': 'Pharmacie Ibn Sina',
        // No opening_hours -> OpenStatus.unknown
      },
    },
  ];

  group('OverpassService', () {
    test('searchNearby fetches, parses, calculates distances, and sorts ascending', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        expect(request.method, 'POST');
        return http.Response(
          json.encode({'elements': sampleElements}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = OverpassService(client: mockClient);
      final results = await service.searchNearby(
        latitude: 36.7538,
        longitude: 3.0588,
        radiusMeters: 5000,
      );

      expect(callCount, 1);
      expect(results.length, 3);
      expect(results[0].name, 'Pharmacie Centrale');
      expect(results[0].distanceMeters, isNotNull);
      // Ensure distance sorting: results[0] <= results[1]
      expect(results[0].distanceMeters! <= results[1].distanceMeters!, isTrue);
    });

    test('searchNearby caches results and avoids repeated network calls', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(
          json.encode({'elements': sampleElements}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = OverpassService(client: mockClient);

      // First call -> hits network
      final first = await service.searchNearby(
        latitude: 36.7538,
        longitude: 3.0588,
        radiusMeters: 5000,
      );
      expect(callCount, 1);

      // Second call same location -> hits cache
      final second = await service.searchNearby(
        latitude: 36.7538,
        longitude: 3.0588,
        radiusMeters: 5000,
      );
      expect(callCount, 1);
      expect(second.length, first.length);

      // Third call with forceRefresh: true -> bypasses cache
      final third = await service.searchNearby(
        latitude: 36.7538,
        longitude: 3.0588,
        radiusMeters: 5000,
        forceRefresh: true,
      );
      expect(callCount, 2);
      expect(third.length, first.length);
    });

    test('searchNearby filters by openNow and includeUnknown', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({'elements': sampleElements}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = OverpassService(client: mockClient, cache: OverpassCache());

      // 1. openNow = true, includeUnknown = false
      // Only 24/7 or open now matches (Pharmacie Centrale is 24/7)
      final openOnly = await service.searchNearby(
        latitude: 36.7538,
        longitude: 3.0588,
        openNow: true,
        includeUnknown: false,
      );
      expect(openOnly.any((p) => p.name == 'Pharmacie Centrale'), isTrue);
      expect(openOnly.any((p) => p.openStatus == OpenStatus.unknown), isFalse);

      // 2. openNow = true, includeUnknown = true
      final openOrUnknown = await service.searchNearby(
        latitude: 36.7538,
        longitude: 3.0588,
        openNow: true,
        includeUnknown: true,
        forceRefresh: true,
      );
      expect(openOrUnknown.any((p) => p.name == 'Pharmacie Ibn Sina'), isTrue);
    });

    test('searchNearby handles mirror failover on HTTP 429 and succeeds on next mirror', () async {
      var attempt = 0;
      final mockClient = MockClient((request) async {
        attempt++;
        if (attempt == 1) {
          // Primary mirror busy
          return http.Response('Rate limit exceeded', 429);
        }
        // Fallback mirror succeeds
        return http.Response(
          json.encode({'elements': sampleElements.take(1).toList()}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = OverpassService(client: mockClient);
      final results = await service.searchNearby(
        latitude: 36.7538,
        longitude: 3.0588,
      );

      expect(attempt, 2);
      expect(results.length, 1);
      expect(results.first.name, 'Pharmacie Centrale');
    });

    test('searchNearby throws OverpassException when all mirrors fail', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = OverpassService(client: mockClient);
      expect(
        () => service.searchNearby(latitude: 36.7538, longitude: 3.0588),
        throwsA(isA<OverpassException>()),
      );
    });

    test('searchByText returns empty list on blank queries', () async {
      final mockClient = MockClient((request) async => http.Response('{}', 200));
      final service = OverpassService(client: mockClient);

      final results = await service.searchByText('   ');
      expect(results, isEmpty);
    });

    test('searchByText escapes special regex characters and returns pharmacies', () async {
      String? sentQuery;
      final mockClient = MockClient((request) async {
        sentQuery = request.bodyFields['data'];
        return http.Response(
          json.encode({'elements': sampleElements.take(1).toList()}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = OverpassService(client: mockClient);
      final results = await service.searchByText('Pharmacie [Algiers] (Center)');

      expect(results.length, 1);
      expect(sentQuery, isNotNull);
      // Brackets and parens should be stripped by _escape
      expect(sentQuery!.contains('[Algiers]'), isFalse);
      expect(sentQuery!.contains('(Center)'), isFalse);
      expect(sentQuery!.contains('Pharmacie Algiers Center'), isTrue);
    });

    test('getDetails queries specific element and returns Pharmacy', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'elements': [sampleElements[0]],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = OverpassService(client: mockClient);
      final pharmacy = await service.getDetails('node', '1001');

      expect(pharmacy, isNotNull);
      expect(pharmacy!.id, '1001');
      expect(pharmacy.name, 'Pharmacie Centrale');
    });

    test('getDetails returns null when element is not found', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({'elements': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = OverpassService(client: mockClient);
      final pharmacy = await service.getDetails('node', '999999');

      expect(pharmacy, isNull);
    });
  });
}
