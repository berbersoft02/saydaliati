# Saydaliati

Cross-platform mobile application to locate open pharmacies nearby using OpenStreetMap and Overpass API data.

## Features

* OpenStreetMap integration with current device location.
* Search by name, area, or current map viewport.
* Real-time open/closed status parsing from OSM opening_hours tags.
* Configurable search radius (2 km, 5 km, 10 km, 15 km).
* Trilingual interface: Arabic (RTL), French, and English.
* Offline device storage for favorite pharmacies.
* Dark and light theme support.

## Project Structure

```
lib/
├── app.dart                     # MaterialApp, localization, and theme setup
├── main.dart                    # Application entry point
├── core/
│   ├── config/app_config.dart   # Endpoints, default coordinates, radius settings
│   ├── services/                # Overpass API, location, and cache services
│   ├── state/app_settings.dart  # User preferences (locale, theme, radius)
│   └── theme/app_theme.dart     # Material 3 light and dark themes
├── features/
│   ├── favorites/               # Saved pharmacies screen
│   ├── home/                    # Map view and nearby list
│   ├── pharmacy_details/        # Contact and details view
│   ├── search/                  # Text-based query screen
│   └── settings/                # Language, radius, and theme options
├── l10n/                        # Localization files (AR, FR, EN)
└── models/pharmacy.dart         # Pharmacy domain model
```

## Setup and Running

Prerequisites: Flutter SDK (>= 3.5.0)

```bash
# Clone the repository
git clone https://github.com/berbersoft02/saydaliati.git
cd saydaliati

# Install dependencies
flutter pub get

# Run unit and widget tests
flutter test

# Run application
flutter run
```

## License

MIT
