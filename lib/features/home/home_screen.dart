import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/services/directions_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/overpass_service.dart';
import '../../core/state/app_settings.dart';
import '../../core/utils/marker_cluster.dart';
import '../../l10n/app_localizations.dart';
import '../../models/pharmacy.dart';
import '../../widgets/pharmacy_card.dart';
import '../favorites/favorites_screen.dart';
import '../pharmacy_details/pharmacy_details_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final OverpassService _overpassService = OverpassService();
  final LocationService _locationService = LocationService();
  final DirectionsService _directions = const DirectionsService();

  Position? _userPosition;
  LatLng? _searchCenter;
  List<Pharmacy> _pharmacies = [];
  Pharmacy? _selected;
  bool _loading = true;
  bool _searchingArea = false;
  String? _error;
  String? _locationWarning;
  bool _showSearchArea = false;
  double _mapZoom = 14;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
      _locationWarning = null;
    });
    try {
      final pos = await _locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _userPosition = pos;
        _searchCenter = LatLng(pos.latitude, pos.longitude);
        _locationWarning = _locationService.lastFallbackReason;
      });
      await _loadPharmacies();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadPharmacies({LatLng? center, bool forceRefresh = false}) async {
    final pos = _userPosition;
    final c = center ??
        _searchCenter ??
        (pos != null ? LatLng(pos.latitude, pos.longitude) : null);
    if (c == null) return;

    final settings = context.read<AppSettings>();
    setState(() {
      _error = null;
      if (center != null) _searchingArea = true;
    });

    try {
      final results = await _overpassService.searchNearby(
        latitude: c.latitude,
        longitude: c.longitude,
        radiusMeters: settings.searchRadiusMeters,
        openNow: settings.openOnlyFilter,
        includeUnknown: settings.includeUnknownWhenOpenOnly,
        forceRefresh: forceRefresh,
      );

      // Recompute distance from real user position when searching another area.
      final withDistance = results.map((p) {
        if (pos == null) return p;
        final d = Pharmacy.haversineDistance(
          pos.latitude,
          pos.longitude,
          p.location.latitude,
          p.location.longitude,
        );
        return p.copyWith(distanceMeters: d);
      }).toList()
        ..sort((a, b) {
          // Open / 24h first, then by distance — easier to scan the list.
          int openRank(Pharmacy x) {
            if (x.openStatus == OpenStatus.alwaysOpen) return 0;
            if (x.openStatus == OpenStatus.open) return 1;
            if (x.openStatus == OpenStatus.unknown) return 2;
            return 3;
          }

          final byOpen = openRank(a).compareTo(openRank(b));
          if (byOpen != 0) return byOpen;
          final da = a.distanceMeters ?? double.infinity;
          final db = b.distanceMeters ?? double.infinity;
          return da.compareTo(db);
        });

      if (!mounted) return;
      setState(() {
        _pharmacies = withDistance;
        _searchCenter = c;
        _showSearchArea = false;
        if (_selected != null) {
          _selected = withDistance.cast<Pharmacy?>().firstWhere(
                (p) => p!.id == _selected!.id,
                orElse: () => null,
              );
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _searchingArea = false;
        });
      }
    }
  }

  void _fitToUser() {
    if (_userPosition == null) return;
    setState(() {
      _locationWarning = null;
      _showSearchArea = false;
    });
    final target = LatLng(_userPosition!.latitude, _userPosition!.longitude);
    _mapController.move(target, 14);
    _loadPharmacies(center: target);
  }

  Future<void> _onDirectionsPressed(Pharmacy p) async {
    final ok = await _directions.openDirections(p);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).noMapsApp)),
      );
    }
  }

  void _onPharmacyTap(Pharmacy p) {
    setState(() => _selected = p);
    _mapController.move(p.location, 16);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PharmacyDetailsScreen(
          pharmacy: p,
          userPosition: _userPosition,
        ),
      ),
    );
  }

  void _onMapMoved(MapCamera camera, bool hasGesture) {
    final zoomChanged = (camera.zoom - _mapZoom).abs() > 0.05;
    if (zoomChanged) {
      setState(() => _mapZoom = camera.zoom);
    }
    if (!hasGesture || _searchCenter == null) return;
    final dist = const Distance().as(
      LengthUnit.Meter,
      _searchCenter!,
      camera.center,
    );
    final shouldShow = dist > 400;
    if (shouldShow != _showSearchArea) {
      setState(() => _showSearchArea = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favorites = context.watch<FavoritesService>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _userPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          _userPosition!.latitude,
                          _userPosition!.longitude,
                        ),
                        initialZoom: 14,
                        minZoom: 3,
                        maxZoom: 19,
                        onTap: (_, __) => setState(() => _selected = null),
                        onPositionChanged: _onMapMoved,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: AppConfig.osmTileUrl,
                          userAgentPackageName: 'app.saydaliati',
                          maxZoom: 19,
                        ),
                        MarkerLayer(markers: _buildMarkers()),
                        const RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            // Top bar
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_locationWarning != null)
                    _LocationWarningBanner(
                      message: l10n.locationFallback,
                      actionLabel: l10n.activateGps,
                      onFixTap: () => Geolocator.openLocationSettings(),
                    ),
                  _SearchBar(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchScreen(
                            userPosition: _userPosition,
                          ),
                        ),
                      );
                      if (mounted) _loadPharmacies();
                    },
                    onSettingsTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                      if (mounted) _loadPharmacies();
                    },
                    onFavoritesTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                  if (_showSearchArea) ...[
                    const SizedBox(height: 8),
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(24),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _searchingArea
                            ? null
                            : () {
                                final center = _mapController.camera.center;
                                _loadPharmacies(center: center);
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchingArea)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.search,
                                  size: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.searchArea,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Map controls (above bottom sheet ~35%)
            Positioned(
              right: 12,
              bottom: MediaQuery.of(context).size.height * 0.38,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    tooltip: l10n.zoomIn,
                    onPressed: () {
                      final cam = _mapController.camera;
                      _mapController.move(cam.center, cam.zoom + 1);
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    tooltip: l10n.zoomOut,
                    onPressed: () {
                      final cam = _mapController.camera;
                      _mapController.move(cam.center, cam.zoom - 1);
                    },
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'recenter',
                    tooltip: l10n.yourLocation,
                    onPressed: _fitToUser,
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),

            // Selected preview
            if (_selected != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: MediaQuery.of(context).size.height * 0.36,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  child: PharmacyCard(
                    pharmacy: _selected!,
                    dense: true,
                    isFavorite: favorites.isFavorite(_selected!.id),
                    onFavoriteToggle: () =>
                        favorites.toggle(_selected!),
                    onTap: () => _onPharmacyTap(_selected!),
                    onDirections: () => _onDirectionsPressed(_selected!),
                  ),
                ),
              ),

            // Bottom sheet
            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.12,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return _BottomSheet(
                  scrollController: scrollController,
                  loading: _loading,
                  error: _error,
                  pharmacies: _pharmacies,
                  openOnly: context.watch<AppSettings>().openOnlyFilter,
                  onRefresh: () => _loadPharmacies(forceRefresh: true),
                  onPharmacyTap: _onPharmacyTap,
                  onDirections: _onDirectionsPressed,
                  onOpenOnlyToggle: (val) async {
                    await context.read<AppSettings>().setOpenOnlyFilter(val);
                    _loadPharmacies();
                  },
                  favorites: favorites,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    if (_userPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.blueAccent,
            size: 40,
          ),
        ),
      );
    }

    final clusters = clusterPharmacies(_pharmacies, zoom: _mapZoom);
    for (final cluster in clusters) {
      if (cluster.isSingle) {
        final p = cluster.first;
        final color = PharmacyCard.statusColorFor(p.openStatus);
        final selected = _selected?.id == p.id;
        markers.add(
          Marker(
            point: p.location,
            width: selected ? 48 : 40,
            height: selected ? 48 : 40,
            child: GestureDetector(
              onTap: () {
                setState(() => _selected = p);
                _mapController.move(p.location, 16);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: selected ? 3 : 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.local_pharmacy,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      } else {
        final size = 40.0 + (cluster.count > 9 ? 8 : 0);
        markers.add(
          Marker(
            point: cluster.center,
            width: size,
            height: size,
            child: GestureDetector(
              onTap: () {
                final nextZoom = (_mapZoom + 1.5).clamp(3.0, 19.0);
                _mapController.move(cluster.center, nextZoom);
                setState(() => _mapZoom = nextZoom);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${cluster.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return markers;
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onFavoritesTap;

  const _SearchBar({
    required this.onTap,
    required this.onSettingsTap,
    required this.onFavoritesTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(28),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.searchHint,
                        style: TextStyle(color: Theme.of(context).hintColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.favorites,
            icon: const Icon(Icons.favorite_border),
            onPressed: onFavoritesTap,
          ),
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings),
            onPressed: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

class _LocationWarningBanner extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onFixTap;

  const _LocationWarningBanner({
    required this.message,
    required this.actionLabel,
    required this.onFixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.amber.shade900.withValues(alpha: 0.35)
            : Colors.amber.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.location_off,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: onFixTap,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final bool loading;
  final String? error;
  final List<Pharmacy> pharmacies;
  final bool openOnly;
  final VoidCallback onRefresh;
  final void Function(Pharmacy) onPharmacyTap;
  final void Function(Pharmacy) onDirections;
  final ValueChanged<bool> onOpenOnlyToggle;
  final FavoritesService favorites;

  const _BottomSheet({
    required this.scrollController,
    required this.loading,
    required this.error,
    required this.pharmacies,
    required this.openOnly,
    required this.onRefresh,
    required this.onPharmacyTap,
    required this.onDirections,
    required this.onOpenOnlyToggle,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<AppSettings>();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.nearbyPharmacies,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (!loading && error == null)
                        Text(
                          l10n.pharmaciesCount(pharmacies.length),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.refresh,
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
                FilterChip(
                  label: Text(l10n.openOnly),
                  selected: settings.openOnlyFilter,
                  onSelected: onOpenOnlyToggle,
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent(context, l10n)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      final scheme = Theme.of(context).colorScheme;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: scheme.error),
            const SizedBox(height: 12),
            Text(l10n.errorOccurred, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scheme.error.withValues(alpha: 0.4)),
              ),
              child: Text(
                error!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: scheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }
    if (pharmacies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_pharmacy_outlined,
                size: 48,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 12),
              Text(
                openOnly ? l10n.noOpenNearby : l10n.noResults,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (openOnly)
                FilledButton.tonal(
                  onPressed: () => onOpenOnlyToggle(false),
                  child: Text(l10n.showAllPharmacies),
                )
              else
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        // Give Overpass a moment; list rebuilds via setState in parent.
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      child: ListView.builder(
        controller: scrollController,
        itemCount: pharmacies.length,
        itemBuilder: (context, i) {
          final p = pharmacies[i];
          return PharmacyCard(
            pharmacy: p,
            isFavorite: favorites.isFavorite(p.id),
            onFavoriteToggle: () => favorites.toggle(p),
            onTap: () => onPharmacyTap(p),
            onDirections: () => onDirections(p),
          );
        },
      ),
    );
  }
}
