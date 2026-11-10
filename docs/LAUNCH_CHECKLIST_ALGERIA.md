# Saydaliati — Algeria Launch Checklist

A practical, ordered list of what to nail down before you push Saydaliati to the Play Store (and later the App Store). Algeria-specific where it matters; otherwise general mobile hygiene.

---

## 0. Sanity (already done ✅)

- [x] `flutter test` → 26/26 green
- [x] `flutter analyze` → no issues in source (run it as a final gate)
- [x] Live `openStatus` evaluation (no more stale "open" pills)
- [x] Last-rule-wins semantics for `opening_hours` overrides
- [x] Project renamed `pharmaciyati` → `saydaliati` (pubspec, bundle IDs, package names, l10n, README)

## 1. Legal & policy (Algeria-specific)

- [ ] **Google Play Console account** — registration is global, but content ratings must be honest.
- [ ] **Privacy policy URL** — required even if you collect nothing. Self-host on `saydaliati.app/privacy` (use a static page: privacy.md, no analytics, no third-party SDKs).
- [ ] **Data safety form** — declare:
  - Location (while using the app) — for pharmacy search
  - No personal data collected
  - No data shared with third parties
- [ ] **No medical claims** — the app is a *finder*, not a *medical service*. Update the store description to make this crystal clear. Add a one-line disclaimer on the home screen.
- [ ] **OpenStreetMap attribution** — must be visible somewhere in-app (you already have it in settings; double-check it survives in the About sheet).

## 2. Real-world data coverage (Algeria)

The biggest risk for an Algerian user is "no pharmacies found". Mitigate before launch:

- [ ] **Audit a 5-km radius around each of the top 10 wilayas** (Algiers, Oran, Constantine, Annaba, Sétif, Tlemcen, Batna, Djelfa, Sidi Bel Abbès, Béjaïa). Open the app, pan, see what's there.
- [ ] **Spot-check "pharmacie de garde" coverage** — OSM tagging is hit-or-miss. Identify the 5 cities with the *worst* coverage and either:
  - add data to OSM yourself (use JOSM / iD editor), or
  - seed a known list of garde pharmacies in-app
- [ ] **Add a "Report missing pharmacy"** button on the details screen → opens a prefilled OSM iD editor URL. Single biggest retention move.

## 3. Scale-proofing (do this BEFORE the launch tweet)

Your README already flags this, but it deserves explicit pre-launch work:

- [ ] **Sign up for Stadia Maps** (free tier = 200k tiles/month) and put the API key behind a `--dart-define=STADIA_KEY=...` build flag.
- [ ] **Replace `AppConfig.osmTileUrl`** with a switch that reads the define; default to OSM public tiles for dev, Stadia for release.
- [ ] **Overpass rate limit guard** — your retry-with-backoff is good. Add a *user-visible* cooldown toast ("Overpass is busy, retrying in 5s…") so people don't keep mashing refresh.
- [ ] **Cache TTL sanity** — your in-memory cache is short. Consider a 24h persistent cache in `shared_preferences` keyed by area, so the second launch of the day is instant.
- [ ] **Pre-warm** the default Algiers tile on app boot, off the critical path.

## 4. Retention & growth (the boring stuff that actually matters)

- [ ] **First-run onboarding** — one screen, three bullets: how it works, why it doesn't need an account, where data comes from. Skip the "swipe left to continue" carousel nonsense.
- [ ] **In-app share sheet polish** — you already have `share_plus`; add a preset WhatsApp message ("La pharmacie la plus proche est à 800m, ouverte jusqu'à 20h : https://osm.org/..."). Algeria is WhatsApp-first.
- [ ] **Lightweight analytics** — `firebase_analytics` is fine, but **don't add it until you have ≥ 1000 DAU** or it's just cost without insight. Counter: if you want to be 100% free, use a self-hosted Plausible or Umami.
- [ ] **Crash reporting** — Sentry free tier covers you. Wire it in *now* before users hit bugs you didn't see in testing.

## 5. Quality gates (last 48h before submit)

- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] `flutter build apk --release` succeeds, install on a real low-end Android (not just your dev phone)
- [ ] Test on **2G / 3G throttle** — many Algerian users are on weak networks. Tile loading + Overpass timeout should both handle 3G gracefully.
- [ ] RTL pass — open the app in Arabic, walk through every screen. Common gotchas: `EdgeInsets` using `start`/`end` (correct) vs `left`/`right` (wrong); icon mirror semantics (`Icons.arrow_back` should flip to forward in RTL).
- [ ] Accessibility — `Semantics` widgets on the map, contrast ratios ≥ 4.5:1 for the status pills (green/red/grey).

## 6. Store listing

- [ ] **Title**: "Saydaliati - صيدليتي - Find a pharmacy"
- [ ] **Short description** (80 chars, EN): "Find the nearest open pharmacy around you. Trilingual, offline-friendly, no ads."
- [ ] **Long description** — three languages. Lead with Arabic, then French, then English. Mirror the README but punchier.
- [ ] **Screenshots** — at least 4 per language (12 total minimum). Show: home map, search, details, settings. RTL screenshots for Arabic.
- [ ] **Feature graphic** — 1024×500, "صيدليتي" prominent, no Google Fonts (use a system Arabic font fallback).
- [ ] **Icon** — your `mipmap-*` icons. Verify they render crisp on a Material You launcher.

## 7. Post-launch (first 7 days)

- [ ] Monitor Overpass errors in Sentry — if you see spikes, swap the primary endpoint in `AppConfig.overpassUrl`.
- [ ] Monitor tile load failures — if non-zero, your Stadia key is misconfigured.
- [ ] Reply to every Play Store review personally in the first week. Algerian users are *very* vocal when listened to.
- [ ] Ship a 1.4.1 patch within 2 weeks if you find any "open" status inaccuracies. That bug category will dominate early reviews.

---

## Out of scope for v1.4 but worth a parking lot

- **Account / cloud sync** for favorites — only build this if a clear % of users complain about losing favorites on phone change.
- **Pharmacie de garde rotation data** — most accurate source is the Ministry of Health daily PDF; you can scrape it nightly and overlay OSM.
- **Monetization** — AdMob in Algeria pays ~$0.30 RPM. Not worth the UX cost. Better: pharmacy partnerships (booking, delivery) once you have 10k+ MAU.
- **iOS launch** — defer until Android DAU > 1k. iOS market share in Algeria is < 5%.

---

## TL;DR — the three things that will make or break launch

1. **Stadia Maps tile key wired up before day one** — public OSM will 429 you on day two if anything goes viral.
2. **Manual OSM data audit for the top 10 cities** — the *app* is great; the *data* in some wilayas isn't.
3. **A real "Report missing pharmacy" button** — turns your users into your data team, and Algeria's OSM community is hungry for contributions.
