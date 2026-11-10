import 'package:url_launcher/url_launcher.dart';

import '../../models/pharmacy.dart';

/// Opens external maps / phone / web for a pharmacy.
class DirectionsService {
  const DirectionsService();

  Future<bool> openDirections(Pharmacy pharmacy) async {
    final lat = pharmacy.location.latitude;
    final lng = pharmacy.location.longitude;
    final name = Uri.encodeComponent(pharmacy.name);

    final geoUri = Uri.parse('geo:$lat,$lng?q=$name');
    final gmapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng&travelmode=driving',
    );
    final osmUri = Uri.parse(
      'https://www.openstreetmap.org/directions?to=$lat%2C$lng',
    );

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
    final cleaned = phone.trim();
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  Future<bool> openWebsite(String url) async {
    var normalized = url.trim();
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null) return false;
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
