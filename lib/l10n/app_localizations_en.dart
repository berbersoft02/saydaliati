// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Saydaliati';

  @override
  String get appTagline => 'Find the nearest open pharmacy';

  @override
  String get nearbyPharmacies => 'Nearby pharmacies';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search a pharmacy or area...';

  @override
  String get openNow => 'Open now';

  @override
  String get closed => 'Closed';

  @override
  String get open24h => 'Open 24/7';

  @override
  String get hoursUnknown => 'Hours unknown';

  @override
  String get getDirections => 'Get directions';

  @override
  String get call => 'Call';

  @override
  String get distance => 'Distance';

  @override
  String get km => 'km';

  @override
  String get m => 'm';

  @override
  String get loading => 'Loading...';

  @override
  String get noResults => 'No pharmacies found';

  @override
  String get locationDenied =>
      'Location permission denied. Please enable it in settings.';

  @override
  String get enableLocation => 'Enable location';

  @override
  String get locationFallback =>
      'Using default location (Algiers). Enable GPS for nearby results.';

  @override
  String get activateGps => 'Enable';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get arabic => 'Arabic';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get address => 'Address';

  @override
  String get phone => 'Phone';

  @override
  String get website => 'Website';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get rating => 'Rating';

  @override
  String get pharmacyOnDuty => 'Pharmacy on duty';

  @override
  String get yourLocation => 'Your location';

  @override
  String get searchArea => 'Search this area';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get openOnly => 'Open only';

  @override
  String directionsTo(String name) {
    return 'Directions to $name';
  }

  @override
  String get errorOccurred => 'An error occurred. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get poweredBy => 'Powered by OpenStreetMap';

  @override
  String get madeWith => 'Made with care in Algeria';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get searchRadius => 'Search radius';

  @override
  String radiusKm(String km) {
    return '$km km';
  }

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavorites =>
      'No favorites yet. Tap the heart on a pharmacy to save it.';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get clearRecent => 'Clear';

  @override
  String get wheelchairAccess => 'Wheelchair access';

  @override
  String get wheelchairYes => 'Accessible';

  @override
  String get wheelchairNo => 'Not accessible';

  @override
  String get wheelchairLimited => 'Limited access';

  @override
  String get wheelchairUnknown => 'Unknown';

  @override
  String get noMapsApp => 'No maps app available';

  @override
  String pharmaciesCount(int count) {
    return '$count pharmacies';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get operator => 'Operator';

  @override
  String get dataSource => 'Map data © OpenStreetMap contributors';

  @override
  String get unnamedPharmacy => 'Pharmacy';

  @override
  String get noOpenNearby =>
      'No open pharmacies nearby. Try turning off “Open only” or increasing the search radius.';

  @override
  String get showAllPharmacies => 'Show all';

  @override
  String get copied => 'Copied';

  @override
  String get share => 'Share';

  @override
  String sharePharmacyText(
      String name, String address, String lat, String lng) {
    return '$name\n$address\nhttps://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=17/$lat/$lng';
  }

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get copyAddress => 'Copy address';

  @override
  String get copyPhone => 'Copy phone';

  @override
  String get includeUnknownHours => 'Include unknown hours';

  @override
  String get includeUnknownHoursSubtitle =>
      'When “Open only” is on, also show pharmacies without opening hours';

  @override
  String get filters => 'Filters';

  @override
  String get shareFailed => 'Could not share';
}
