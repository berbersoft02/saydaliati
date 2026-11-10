/// App-wide configuration. No API key required — Saydaliati uses
/// OpenStreetMap tiles + Overpass API, which are free and open.
class AppConfig {
  static const String appName = 'Saydaliati';
  static const String appVersion = '1.4.0';

  /// Neutral fallback when OSM has no name tag (UI may localize further).
  static const String defaultPharmacyName = 'Pharmacy';

  /// Default country (used for analytics / future server-side filters).
  static const String defaultCountry = 'DZ';

  /// Default map center: Algiers, Algeria.
  static const double defaultLatitude = 36.7538;
  static const double defaultLongitude = 3.0588;

  /// Default search radius around the user in meters.
  static const int searchRadiusMeters = 5000;

  static const List<int> radiusOptionsMeters = [2000, 5000, 10000];

  /// Tile server URL. Public OpenStreetMap tiles — please respect the
  /// tile usage policy (https://operations.osmfoundation.org/policies/tiles/).
  /// For production with many users, switch to a self-hosted tile server
  /// or a provider like Stadia Maps (free tier available).
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Primary Overpass API endpoint.
  static const String overpassUrl = 'https://overpass-api.de/api/interpreter';

  /// Fallback Overpass mirror.
  static const String overpassFallbackUrl =
      'https://overpass.kumi.systems/api/interpreter';

  /// User-Agent sent to Overpass and the tile server. Overpass rejects
  /// requests with a generic / empty User-Agent (HTTP 406).
  static const String userAgent = 'saydaliati/1.4 (https://saydaliati.app)';
}
