import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:saydaliati/core/services/directions_service.dart';
import 'package:saydaliati/models/pharmacy.dart';

void main() {
  const pharmacy = Pharmacy(
    id: '99',
    name: 'Pharmacie Ibn Rochd',
    address: 'Place du 1er Mai, Alger',
    location: LatLng(36.755, 3.060),
  );

  group('DirectionsService', () {
    test('buildGeoUri encodes location and encoded pharmacy name', () {
      final uri = DirectionsService.buildGeoUri(pharmacy);
      expect(uri.scheme, 'geo');
      expect(uri.path, '36.755,3.06');
      expect(uri.queryParameters['q'], 'Pharmacie Ibn Rochd');
    });

    test('buildGoogleMapsUri contains correct coordinates and driving mode', () {
      final uri = DirectionsService.buildGoogleMapsUri(pharmacy);
      expect(uri.scheme, 'https');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters['destination'], '36.755,3.06');
      expect(uri.queryParameters['travelmode'], 'driving');
    });

    test('buildOsmUri points to openstreetmap directions with destination coords', () {
      final uri = DirectionsService.buildOsmUri(pharmacy);
      expect(uri.scheme, 'https');
      expect(uri.host, 'www.openstreetmap.org');
      expect(uri.path, '/directions');
      expect(uri.queryParameters['to'], '36.755,3.06');
    });

    test('buildTelUri trims whitespace and creates tel scheme', () {
      final uri = DirectionsService.buildTelUri('  +213 21 00 11 22  ');
      expect(uri.scheme, 'tel');
      expect(Uri.decodeComponent(uri.path), '+213 21 00 11 22');
    });

    test('normalizeWebsiteUri handles standard http and https urls', () {
      final httpUri = DirectionsService.normalizeWebsiteUri('http://pharmacie.dz');
      expect(httpUri, isNotNull);
      expect(httpUri!.scheme, 'http');
      expect(httpUri.host, 'pharmacie.dz');

      final httpsUri = DirectionsService.normalizeWebsiteUri('https://pharmacie.dz/shop');
      expect(httpsUri, isNotNull);
      expect(httpsUri!.scheme, 'https');
      expect(httpsUri.path, '/shop');
    });

    test('normalizeWebsiteUri prefixes missing schemes with https', () {
      final uri = DirectionsService.normalizeWebsiteUri('  pharmacie.dz/portal  ');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'https');
      expect(uri.host, 'pharmacie.dz');
      expect(uri.path, '/portal');
    });

    test('normalizeWebsiteUri returns null for empty or invalid strings', () {
      expect(DirectionsService.normalizeWebsiteUri(''), isNull);
      expect(DirectionsService.normalizeWebsiteUri('   '), isNull);
    });
  });
}
