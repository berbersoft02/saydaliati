# Saydaliati Full Upgrade Design

**Date:** 2026-07-19  
**Status:** Approved

## Goal

Make Saydaliati a trustworthy daily pharmacy finder for Algeria: accurate open/closed status, polished trilingual UX, cleaner architecture, and high-value local features — still 100% free (OSM + Overpass, no API keys).

## Scope

### In scope
- Real OSM `opening_hours` evaluation (common cases)
- Honest status: Open / Closed / 24h / Unknown
- i18n fixes (EN/FR/AR + RTL), no hard-coded French
- Dark mode, radius selector, favorites, recent searches
- Search this map area, marker preview, shared directions/call helpers
- Overpass primary + fallback servers with retry
- Unit tests for hours + distance + parsing

### Out of scope
- Accounts, cloud sync, ads, Google Places, offline map packs, fake duty roster without OSM data

## Architecture

```
lib/
  core/
    config/app_config.dart
    services/
      opening_hours_service.dart
      overpass_service.dart
      location_service.dart
      directions_service.dart
      favorites_service.dart
    state/app_settings.dart
    theme/app_theme.dart
  models/pharmacy.dart          # OpenStatus enum
  features/...
  widgets/
```

## Key behaviors

1. **Opening hours:** Parse common OSM syntax; unknown hours → Unknown (not Closed).
2. **Open-only filter:** Keep open + alwaysOpen; optional unknown inclusion later if needed.
3. **Map:** Search this area when user pans; recenter; selected marker preview card.
4. **Settings:** Language, theme (system/light/dark), radius (2/5/10 km), about + OSM credit.
5. **Favorites:** Local SharedPreferences by pharmacy id + snapshot fields.

## Success criteria

- Correct open/closed for `Mo-Fr 08:00-19:00` at a known time
- Missing hours show Unknown
- AR/FR/EN consistent
- Dark mode works
- Favorites + radius persist
- Unit tests for opening hours pass
