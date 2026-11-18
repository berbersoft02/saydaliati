import 'package:url_launcher/url_launcher.dart';

import '../../models/pharmacy.dart';

/// Opens external maps / phone / web for a pharmacy.
class DirectionsService {
  const DirectionsService();

  static Uri buildGeoUri(Pharmacy pharmacy) {
    final lat = pharmacy.location.latitude;
    final lng = pharmacy.location.longitude;
    final name = Uri.encodeComponent(pharmacy.name);
    return Uri.parse('geo:$lat,$lng?q=$name');
  }

  static Uri buildGoogleMapsUri(Pharmacy pharmacy) {
    final lat = pharmacy.location.latitude;
    final lng = pharmacy.location.longitude;
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng&travelmode=driving',
    );
  }

  static Uri buildOsmUri(Pharmacy pharmacy) {
    final lat = pharmacy.location.latitude;
    final lng = pharmacy.location.longitude;
    return Uri.parse(
      'https://www.openstreetmap.org/directions?to=$lat%2C$lng',
    );
  }

  static Uri buildTelUri(String phone) {
    return Uri(scheme: 'tel', path: phone.trim());
  }

  static Uri? normalizeWebsiteUri(String url) {
    var normalized = url.trim();
    if (normalized.isEmpty) return null;
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    return Uri.tryParse(normalized);
  }

  Future<bool> openDirections(Pharmacy pharmacy) async {
    final geoUri = buildGeoUri(pharmacy);
    final gmapsUri = buildGoogleMapsUri(pharmacy);
    final osmUri = buildOsmUri(pharmacy);

    if (await canLaunchUrl(geoUri)) {
      return launchUrl(geoUri);
    }
    if (await canLaunchUrl(gmapsUri)) {
      return launchUrl(gmapsUri, mode: LaunchMode.externalApplication);
    }
    if (await canLaunchUrl(osmUri)) {
      return launchUrl(osmUri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  Future<bool> callPhone(String phone) async {
    final uri = buildTelUri(phone);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  Future<bool> openWebsite(String url) async {
    final uri = normalizeWebsiteUri(url);
    if (uri == null) return false;
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
