# Saydaliati 💊

Find the nearest open pharmacy around you — built with Flutter + **OpenStreetMap**.
**100% free, no API key, no quota, no surprise bills.**

**Features**
- 🗺️ Live OpenStreetMap with your current location
- 💊 Nearby pharmacies, sorted by distance
- 🟢 Real open/closed status from OSM hours (plus 24/7 & unknown)
- 🔍 Search by name or area + recent searches
- 📍 Search this map area when you pan
- ❤️ Favorites (saved on device)
- 🧭 One-tap directions / 📞 call / website
- 🌐 Trilingual: **Arabic (RTL) + French + English**
- 🌙 Dark mode (system / light / dark)
- 📏 Search radius 2 / 5 / 10 km
- ♿ Wheelchair accessibility when tagged in OSM

---

## ⚙️ Setup in 3 minutes

### 1. Install Flutter

Already done if you ran `flutter doctor` ✅

### 2. Get the code

```bash
cd saydaliati
flutter pub get
```

### 3. Run on your phone

```bash
flutter run
```

**That's it.** No API key, no Google Cloud account, no credit card.

---

## 📱 Testing on a real Android phone

1. **Settings → About phone → tap "Build number" 7 times** (enables developer options)
2. **Settings → Developer options → enable USB debugging**
3. Plug phone via USB
4. `flutter devices` — your phone should appear
5. `flutter run`

---

## 💰 Why OpenStreetMap and not Google Maps?

Google Maps Platform is **free up to ~$200/month** of usage, but a real pharmacy
finder quickly blows past that:

| Scale | Google Places cost | Overpass cost |
|---|---|---|
| 1 user / day | Free | Free |
| 1 000 users / day | ~$300/month | Free |
| 10 000 users / day | ~$3 000/month | Free |

OSM is the same map data that powers Facebook, Apple Maps, Snapchat, and Wikipedia.
The pharmacy data is community-maintained and **especially good in Algeria** thanks
to the active local OSM community.

### Caveats

- Tile usage policy: respect https://operations.osmfoundation.org/policies/tiles/
  (don't deploy with hundreds of users on the public tile server — self-host or
  use a provider like Stadia Maps for production).
- Overpass API has a soft rate limit. We retry with backoff in the app.

---

## 🗂️ Project structure

```
lib/
├── main.dart
├── app.dart                     # MaterialApp + i18n + theme + providers
├── core/
│   ├── config/app_config.dart
│   ├── services/
│   │   ├── location_service.dart
│   │   ├── overpass_service.dart      # primary + fallback + cache
│   │   ├── overpass_cache.dart
│   │   ├── opening_hours_service.dart # OSM opening_hours parser
│   │   ├── directions_service.dart
│   │   └── favorites_service.dart
│   ├── utils/marker_cluster.dart
│   ├── state/app_settings.dart        # locale, theme, radius, filters
│   └── theme/app_theme.dart           # light + dark Material 3
├── features/
│   ├── home/                    # Map + list + search-this-area + clusters
│   ├── search/                  # Text search + recents
│   ├── favorites/               # Saved pharmacies
│   ├── pharmacy_details/        # Info + share + favorite
│   └── settings/                # Language, theme, radius, filters
├── l10n/                        # EN / FR / AR
├── models/pharmacy.dart
└── widgets/pharmacy_card.dart
```

---

## 🌍 Default location

The app boots centered on **Algiers, Algeria** (configurable in `lib/core/config/app_config.dart`).
Once you grant location permission, it animates to your real position.

---

## 🛠️ Common issues

- **Tiles don't load** → check your internet connection. OSM tiles are served from
  public servers; if you're behind a corporate firewall, allow `*.tile.openstreetmap.org`.
- **"No pharmacies found"** → you might be in an area with low OSM coverage for
  Algeria, or your radius is too small. Try tapping "Search" and look for a city
  (e.g. "Hydra", "Bab Ezzouar", "Kouba").
- **Overpass timeout** → the public server is occasionally overloaded. Pull to
  refresh and try again.
- **Phone doesn't show in `flutter devices`** → USB cable must support data
  (not charge-only), enable USB debugging, accept the RSA fingerprint popup.

---

## 🚀 Going to production

For an app with real users, you should:

1. **Switch tile provider** — sign up for [Stadia Maps](https://stadiamaps.com/)
   (free tier = 200 000 tile requests/month) or self-host tiles.
2. **Deploy a private Overpass instance** if you exceed the public rate limit.
3. **Contribute back to OSM** — encourage users to add missing pharmacies via
   the OpenStreetMap editors.
4. **Add analytics** (e.g. `firebase_analytics`) to understand your audience.
5. **Add monetization** — AdMob, premium features, or pharmacy partnerships.

---

## 📄 License

MIT — make it yours. And if it makes money, consider a donation to the
[OpenStreetMap Foundation](https://support.openstreetmap.org/). 🗺️
