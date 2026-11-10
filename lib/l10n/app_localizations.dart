import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Saydaliati'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Find the nearest open pharmacy'**
  String get appTagline;

  /// No description provided for @nearbyPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Nearby pharmacies'**
  String get nearbyPharmacies;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a pharmacy or area...'**
  String get searchHint;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @open24h.
  ///
  /// In en, this message translates to:
  /// **'Open 24/7'**
  String get open24h;

  /// No description provided for @hoursUnknown.
  ///
  /// In en, this message translates to:
  /// **'Hours unknown'**
  String get hoursUnknown;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get getDirections;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @m.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get m;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No pharmacies found'**
  String get noResults;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Please enable it in settings.'**
  String get locationDenied;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get enableLocation;

  /// No description provided for @locationFallback.
  ///
  /// In en, this message translates to:
  /// **'Using default location (Algiers). Enable GPS for nearby results.'**
  String get locationFallback;

  /// No description provided for @activateGps.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get activateGps;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get openingHours;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @pharmacyOnDuty.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy on duty'**
  String get pharmacyOnDuty;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get yourLocation;

  /// No description provided for @searchArea.
  ///
  /// In en, this message translates to:
  /// **'Search this area'**
  String get searchArea;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @openOnly.
  ///
  /// In en, this message translates to:
  /// **'Open only'**
  String get openOnly;

  /// No description provided for @directionsTo.
  ///
  /// In en, this message translates to:
  /// **'Directions to {name}'**
  String directionsTo(String name);

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurred;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by OpenStreetMap'**
  String get poweredBy;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with care in Algeria'**
  String get madeWith;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @searchRadius.
  ///
  /// In en, this message translates to:
  /// **'Search radius'**
  String get searchRadius;

  /// No description provided for @radiusKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String radiusKm(String km);

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet. Tap the heart on a pharmacy to save it.'**
  String get noFavorites;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @clearRecent.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearRecent;

  /// No description provided for @wheelchairAccess.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair access'**
  String get wheelchairAccess;

  /// No description provided for @wheelchairYes.
  ///
  /// In en, this message translates to:
  /// **'Accessible'**
  String get wheelchairYes;

  /// No description provided for @wheelchairNo.
  ///
  /// In en, this message translates to:
  /// **'Not accessible'**
  String get wheelchairNo;

  /// No description provided for @wheelchairLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited access'**
  String get wheelchairLimited;

  /// No description provided for @wheelchairUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get wheelchairUnknown;

  /// No description provided for @noMapsApp.
  ///
  /// In en, this message translates to:
  /// **'No maps app available'**
  String get noMapsApp;

  /// No description provided for @pharmaciesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pharmacies'**
  String pharmaciesCount(int count);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @operator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operator;

  /// No description provided for @dataSource.
  ///
  /// In en, this message translates to:
  /// **'Map data © OpenStreetMap contributors'**
  String get dataSource;

  /// No description provided for @unnamedPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get unnamedPharmacy;

  /// No description provided for @noOpenNearby.
  ///
  /// In en, this message translates to:
  /// **'No open pharmacies nearby. Try turning off “Open only” or increasing the search radius.'**
  String get noOpenNearby;

  /// No description provided for @showAllPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAllPharmacies;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @sharePharmacyText.
  ///
  /// In en, this message translates to:
  /// **'{name}\n{address}\nhttps://www.openstreetmap.org/?mlat={lat}&mlon={lng}#map=17/{lat}/{lng}'**
  String sharePharmacyText(String name, String address, String lat, String lng);

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @copyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get copyAddress;

  /// No description provided for @copyPhone.
  ///
  /// In en, this message translates to:
  /// **'Copy phone'**
  String get copyPhone;

  /// No description provided for @includeUnknownHours.
  ///
  /// In en, this message translates to:
  /// **'Include unknown hours'**
  String get includeUnknownHours;

  /// No description provided for @includeUnknownHoursSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When “Open only” is on, also show pharmacies without opening hours'**
  String get includeUnknownHoursSubtitle;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share'**
  String get shareFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
