import '../../models/pharmacy.dart';

/// Short-lived in-memory cache for Overpass results.
///
/// Keys are rounded so tiny GPS / pan jitter reuses the same entry.
class OverpassCache {
  OverpassCache({this.ttl = const Duration(minutes: 3), this.maxEntries = 24});

  final Duration ttl;
  final int maxEntries;
  final Map<String, _CacheEntry> _entries = {};

  List<Pharmacy>? get(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _entries.remove(key);
      return null;
    }
    // Return a shallow copy so callers can sort/filter freely.
    return List<Pharmacy>.from(entry.pharmacies);
  }

  void put(String key, List<Pharmacy> pharmacies) {
    if (_entries.length >= maxEntries) {
      // Drop oldest by expiry.
      final oldest = _entries.entries.toList()
        ..sort((a, b) => a.value.expiresAt.compareTo(b.value.expiresAt));
      if (oldest.isNotEmpty) {
        _entries.remove(oldest.first.key);
      }
    }
    _entries[key] = _CacheEntry(
      pharmacies: List<Pharmacy>.from(pharmacies),
      expiresAt: DateTime.now().add(ttl),
    );
  }

  void clear() => _entries.clear();

  /// Nearby key: lat/lng rounded to ~100 m + radius.
  static String nearbyKey({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) {
    final lat = (latitude * 1000).round() / 1000;
    final lng = (longitude * 1000).round() / 1000;
    return 'n:$lat,$lng,$radiusMeters';
  }

  static String textKey({
    required String query,
    required double latitude,
    required double longitude,
  }) {
    final lat = (latitude * 100).round() / 100;
    final lng = (longitude * 100).round() / 100;
    return 't:${query.trim().toLowerCase()}|$lat,$lng';
  }
}

class _CacheEntry {
  final List<Pharmacy> pharmacies;
  final DateTime expiresAt;

  _CacheEntry({required this.pharmacies, required this.expiresAt});
}
