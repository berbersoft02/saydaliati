import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/pharmacy.dart';
import '../config/app_config.dart';
import 'overpass_cache.dart';

/// Client for the OpenStreetMap Overpass API.
///
/// Uses primary + fallback public servers with automatic retry on 429/504,
/// plus a short in-memory cache to avoid hammering mirrors when panning.
class OverpassService {
  final http.Client _client;
  final OverpassCache _cache;

  static const _endpoints = [
    AppConfig.overpassUrl,
    AppConfig.overpassFallbackUrl,
  ];

  OverpassService({
    http.Client? client,
    OverpassCache? cache,
  })  : _client = client ?? http.Client(),
        _cache = cache ?? OverpassCache();

  /// Returns pharmacies within [radiusMeters] of (lat, lng),
  /// sorted by distance ascending.
  ///
  /// [openNow] keeps open / 24h; when [includeUnknown] is true, unknown hours
  /// are kept too (only applies when [openNow] is true).
  Future<List<Pharmacy>> searchNearby({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    bool openNow = false,
    bool includeUnknown = false,
    bool forceRefresh = false,
  }) async {
    final key = OverpassCache.nearbyKey(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );

    List<Pharmacy> results;
    if (!forceRefresh) {
      final cached = _cache.get(key);
      if (cached != null) {
        results = cached;
      } else {
        results = await _fetchNearby(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        );
        _cache.put(key, results);
      }
    } else {
      results = await _fetchNearby(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );
      _cache.put(key, results);
    }

    // Re-evaluate distances from the request center (cache may be nearby).
    results = results.map((p) {
      final d = Pharmacy.haversineDistance(
        latitude,
        longitude,
        p.location.latitude,
        p.location.longitude,
      );
      return p.copyWith(distanceMeters: d);
    }).toList();

    if (openNow) {
      results = results.where((p) {
        if (p.isOpen) return true;
        if (includeUnknown && p.openStatus == OpenStatus.unknown) return true;
        return false;
      }).toList();
    }

    results.sort((a, b) {
      final da = a.distanceMeters ?? double.infinity;
      final db = b.distanceMeters ?? double.infinity;
      return da.compareTo(db);
    });
    return results;
  }

  Future<List<Pharmacy>> _fetchNearby({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    final query = _buildNearbyQuery(
      latitude: latitude,
      longitude: longitude,
      radius: radiusMeters,
    );

    final response = await _post(query);
    final elements = (response['elements'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return elements
        .map(
          (e) => Pharmacy.fromOverpass(
            e,
            userLat: latitude,
            userLng: longitude,
          ),
        )
        .where((p) => p.location.latitude != 0 && p.location.longitude != 0)
        .toList();
  }

  /// Free text search limited to a ~10 km box around the user.
  Future<List<Pharmacy>> searchByText(
    String query, {
    double? latitude,
    double? longitude,
    bool forceRefresh = false,
  }) async {
    if (query.trim().isEmpty) return const [];

    final lat = latitude ?? AppConfig.defaultLatitude;
    final lng = longitude ?? AppConfig.defaultLongitude;
    final key = OverpassCache.textKey(
      query: query,
      latitude: lat,
      longitude: lng,
    );

    if (!forceRefresh) {
      final cached = _cache.get(key);
      if (cached != null) return cached;
    }

    const delta = 0.1; // ~11 km
    final south = lat - delta;
    final west = lng - delta;
    final north = lat + delta;
    final east = lng + delta;

    final safe = _escape(query);
    final ql = '''
[out:json][timeout:25];
(
  node["amenity"="pharmacy"]["name"~"$safe",i]($south,$west,$north,$east);
  way["amenity"="pharmacy"]["name"~"$safe",i]($south,$west,$north,$east);
  relation["amenity"="pharmacy"]["name"~"$safe",i]($south,$west,$north,$east);
);
out center tags;
''';
    final response = await _post(ql);
    final elements = (response['elements'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final results = elements
        .map(
          (e) => Pharmacy.fromOverpass(
            e,
            userLat: latitude,
            userLng: longitude,
          ),
        )
        .where((p) => p.location.latitude != 0 && p.location.longitude != 0)
        .toList();
    results.sort((a, b) {
      final da = a.distanceMeters ?? double.infinity;
      final db = b.distanceMeters ?? double.infinity;
      return da.compareTo(db);
    });
    _cache.put(key, results);
    return results;
  }

  Future<Pharmacy?> getDetails(
    String osmType,
    String osmId, {
    double? userLat,
    double? userLng,
  }) async {
    final ql = '''
[out:json][timeout:15];
$osmType($osmId);
out center tags;
''';
    final response = await _post(ql);
    final elements = (response['elements'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (elements.isEmpty) return null;
    return Pharmacy.fromOverpass(
      elements.first,
      userLat: userLat,
      userLng: userLng,
    );
  }

  void clearCache() => _cache.clear();

  String _buildNearbyQuery({
    required double latitude,
    required double longitude,
    required int radius,
  }) {
    return '''
[out:json][timeout:25];
(
  node["amenity"="pharmacy"](around:$radius,$latitude,$longitude);
  way["amenity"="pharmacy"](around:$radius,$latitude,$longitude);
  relation["amenity"="pharmacy"](around:$radius,$latitude,$longitude);
);
out center tags;
''';
  }

  Future<Map<String, dynamic>> _post(String query) async {
    const maxAttempts = 3;
    Object? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final endpoint = _endpoints[(attempt - 1) % _endpoints.length];
      try {
        final response = await _client
            .post(
              Uri.parse(endpoint),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': '*/*',
                'User-Agent': AppConfig.userAgent,
              },
              body: {'data': query},
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 429 || response.statusCode == 504) {
          lastError = 'HTTP ${response.statusCode} from $endpoint';
          await Future.delayed(Duration(seconds: 2 * attempt));
          continue;
        }
        if (response.statusCode != 200) {
          throw OverpassException(
            'Overpass returned ${response.statusCode}: ${response.body}',
          );
        }
        final body = json.decode(response.body);
        if (body is! Map) {
          throw OverpassException('Unexpected Overpass response shape');
        }
        return Map<String, dynamic>.from(body);
      } on TimeoutException {
        lastError = 'timeout';
        if (attempt == maxAttempts) {
          throw OverpassException('Overpass request timed out');
        }
        await Future.delayed(Duration(seconds: 2 * attempt));
      } catch (e) {
        lastError = e;
        if (e is OverpassException && attempt == maxAttempts) rethrow;
        if (attempt == maxAttempts) {
          throw OverpassException('Overpass request failed: $e');
        }
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }
    throw OverpassException(
      'Overpass request failed after $maxAttempts attempts: $lastError',
    );
  }

  String _escape(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('[', '')
      .replaceAll(']', '')
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll('|', '')
      .replaceAll('~', '');
}

class OverpassException implements Exception {
  final String message;
  OverpassException(this.message);
  @override
  String toString() => message;
}
