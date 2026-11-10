// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Saydaliati';

  @override
  String get appTagline => 'Trouvez la pharmacie ouverte la plus proche';

  @override
  String get nearbyPharmacies => 'Pharmacies à proximité';

  @override
  String get search => 'Rechercher';

  @override
  String get searchHint => 'Chercher une pharmacie ou un quartier...';

  @override
  String get openNow => 'Ouvert maintenant';

  @override
  String get closed => 'Fermé';

  @override
  String get open24h => 'Ouvert 24h/24';

  @override
  String get hoursUnknown => 'Horaires inconnus';

  @override
  String get getDirections => 'Itinéraire';

  @override
  String get call => 'Appeler';

  @override
  String get distance => 'Distance';

  @override
  String get km => 'km';

  @override
  String get m => 'm';

  @override
  String get loading => 'Chargement...';

  @override
  String get noResults => 'Aucune pharmacie trouvée';

  @override
  String get locationDenied =>
      'Autorisation de localisation refusée. Veuillez l\'activer dans les paramètres.';

  @override
  String get enableLocation => 'Activer la localisation';

  @override
  String get locationFallback =>
      'Position par défaut (Alger). Activez le GPS pour des résultats près de vous.';

  @override
  String get activateGps => 'Activer';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'Arabe';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get address => 'Adresse';

  @override
  String get phone => 'Téléphone';

  @override
  String get website => 'Site web';

  @override
  String get openingHours => 'Horaires d\'ouverture';

  @override
  String get rating => 'Note';

  @override
  String get pharmacyOnDuty => 'Pharmacie de garde';

  @override
  String get yourLocation => 'Votre position';

  @override
  String get searchArea => 'Rechercher dans cette zone';

  @override
  String get filter => 'Filtrer';

  @override
  String get all => 'Toutes';

  @override
  String get openOnly => 'Ouvertes uniquement';

  @override
  String directionsTo(String name) {
    return 'Itinéraire vers $name';
  }

  @override
  String get errorOccurred => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get retry => 'Réessayer';

  @override
  String get poweredBy => 'Propulsé par OpenStreetMap';

  @override
  String get madeWith => 'Fait avec soin en Algérie';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get searchRadius => 'Rayon de recherche';

  @override
  String radiusKm(String km) {
    return '$km km';
  }

  @override
  String get favorites => 'Favoris';

  @override
  String get noFavorites =>
      'Aucun favori. Appuyez sur le cœur d\'une pharmacie pour l\'enregistrer.';

  @override
  String get recentSearches => 'Recherches récentes';

  @override
  String get clearRecent => 'Effacer';

  @override
  String get wheelchairAccess => 'Accès PMR';

  @override
  String get wheelchairYes => 'Accessible';

  @override
  String get wheelchairNo => 'Non accessible';

  @override
  String get wheelchairLimited => 'Accès limité';

  @override
  String get wheelchairUnknown => 'Inconnu';

  @override
  String get noMapsApp => 'Aucune application de cartes disponible';

  @override
  String pharmaciesCount(int count) {
    return '$count pharmacies';
  }

  @override
  String get refresh => 'Actualiser';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get operator => 'Exploitant';

  @override
  String get dataSource =>
      'Données cartographiques © contributeurs OpenStreetMap';

  @override
  String get unnamedPharmacy => 'Pharmacie';

  @override
  String get noOpenNearby =>
      'Aucune pharmacie ouverte à proximité. Désactivez « Ouvertes uniquement » ou élargissez le rayon.';

  @override
  String get showAllPharmacies => 'Tout afficher';

  @override
  String get copied => 'Copié';

  @override
  String get share => 'Partager';

  @override
  String sharePharmacyText(
      String name, String address, String lat, String lng) {
    return '$name\n$address\nhttps://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=17/$lat/$lng';
  }

  @override
  String get zoomIn => 'Zoom avant';

  @override
  String get zoomOut => 'Zoom arrière';

  @override
  String get copyAddress => 'Copier l\'adresse';

  @override
  String get copyPhone => 'Copier le téléphone';

  @override
  String get includeUnknownHours => 'Inclure horaires inconnus';

  @override
  String get includeUnknownHoursSubtitle =>
      'Avec « Ouvertes uniquement », afficher aussi les pharmacies sans horaires';

  @override
  String get filters => 'Filtres';

  @override
  String get shareFailed => 'Partage impossible';
}
