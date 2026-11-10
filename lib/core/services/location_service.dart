import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';

/// Wraps geolocator with the permission flow + sensible defaults.
class LocationService {
  /// Returns the current position, falling back to the default city
  /// (Algiers) on any failure. The reason for the fallback is exposed
  /// via [lastFallbackReason] and via debug logs.
  Future<Position> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _fallback('Location services disabled (GPS off)');
        return _defaultPosition();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _fallback('Location permission denied by user');
          return _defaultPosition();
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _fallback('Location permission denied forever');
        return _defaultPosition();
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      _fallback('Exception: $e');
      return _defaultPosition();
    }
  }

  String? _fallback(String reason) {
    debugPrint('[LocationService] FALLBACK to default: $reason');
    lastFallbackReason = reason;
    return reason;
  }

  /// Set after a fallback; cleared on a successful real fix.
  /// Null when the position returned by [getCurrentPosition] is real.
  String? lastFallbackReason;

  Position _defaultPosition() => Position(
        latitude: AppConfig.defaultLatitude,
        longitude: AppConfig.defaultLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

  /// Compute distance string ("1.2 km" / "350 m") for display.
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}
