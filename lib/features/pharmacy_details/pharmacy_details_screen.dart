import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_config.dart';
import '../../core/services/directions_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/location_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/pharmacy.dart';
import '../../widgets/pharmacy_card.dart';

class PharmacyDetailsScreen extends StatefulWidget {
  final Pharmacy pharmacy;
  final Position? userPosition;
  final bool openDirections;

  const PharmacyDetailsScreen({
    super.key,
    required this.pharmacy,
    this.userPosition,
    this.openDirections = false,
  });

  @override
  State<PharmacyDetailsScreen> createState() => _PharmacyDetailsScreenState();
}

class _PharmacyDetailsScreenState extends State<PharmacyDetailsScreen> {
  late Pharmacy _pharmacy;
  final _directions = const DirectionsService();

  @override
  void initState() {
    super.initState();
    _pharmacy = widget.pharmacy;
    if (widget.openDirections) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openDirections();
      });
    }
  }

  Future<void> _openDirections() async {
    final ok = await _directions.openDirections(_pharmacy);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).noMapsApp)),
      );
    }
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).copied)),
    );
  }

  Future<void> _sharePharmacy() async {
    final l10n = AppLocalizations.of(context);
    final p = _pharmacy;
    final lat = p.location.latitude.toStringAsFixed(5);
    final lng = p.location.longitude.toStringAsFixed(5);
    final text = l10n.sharePharmacyText(
      p.name,
      p.address.isEmpty ? '—' : p.address,
      lat,
      lng,
    );
    try {
      await SharePlus.instance.share(ShareParams(text: text, subject: p.name));
    } catch (_) {
      // Fallback: copy to clipboard if the share sheet fails.
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.copied)),
      );
    }
  }

  String _wheelchairLabel(AppLocalizations l10n, String? value) {
    switch (value) {
      case 'yes':
        return l10n.wheelchairYes;
      case 'no':
        return l10n.wheelchairNo;
      case 'limited':
        return l10n.wheelchairLimited;
      default:
        return l10n.wheelchairUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = _pharmacy;
    final favorites = context.watch<FavoritesService>();
    final isFav = favorites.isFavorite(p.id);
    final statusColor = PharmacyCard.statusColorFor(p.openStatus);
    final statusText = PharmacyCard.statusLabel(p, l10n);
    final displayName =
        p.name == 'Pharmacy' ? l10n.unnamedPharmacy : p.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: [
          IconButton(
            tooltip: l10n.share,
            icon: const Icon(Icons.share),
            onPressed: _sharePharmacy,
          ),
          IconButton(
            tooltip: isFav ? l10n.removeFavorite : l10n.addFavorite,
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : null,
            ),
            onPressed: () => favorites.toggle(p),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: p.location,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: AppConfig.osmTileUrl,
                  userAgentPackageName: 'app.saydaliati',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: p.location,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.local_pharmacy,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (p.isOnDuty) ...[
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.nightlight_round, size: 16),
                    label: Text(l10n.pharmacyOnDuty),
                  ),
                ],
                if (p.distanceMeters != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.near_me, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.distance}: '
                        '${LocationService.formatDistance(p.distanceMeters!)}',
                      ),
                    ],
                  ),
                ],
                if (p.operator != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${l10n.operator}: ${p.operator}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (p.address.isNotEmpty) ...[
                  _InfoRow(
                    icon: Icons.place,
                    label: l10n.address,
                    value: p.address,
                    onTap: () => _copy(p.address),
                    actionTooltip: l10n.copyAddress,
                  ),
                  const SizedBox(height: 8),
                ],
                if (p.phone != null && p.phone!.isNotEmpty) ...[
                  _InfoRow(
                    icon: Icons.phone,
                    label: l10n.phone,
                    value: p.phone!,
                    onTap: () => _directions.callPhone(p.phone!),
                    onLongPress: () => _copy(p.phone!),
                    actionTooltip: l10n.call,
                    trailingIcon: Icons.call,
                  ),
                  const SizedBox(height: 8),
                ],
                if (p.website != null && p.website!.isNotEmpty) ...[
                  _InfoRow(
                    icon: Icons.language,
                    label: l10n.website,
                    value: p.website!,
                    onTap: () => _directions.openWebsite(p.website!),
                  ),
                  const SizedBox(height: 8),
                ],
                if (p.openingHours.isNotEmpty) ...[
                  Text(
                    l10n.openingHours,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  ...p.openingHours.map(
                    (h) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        h,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    l10n.openingHours,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.hoursUnknown,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ],
                if (p.wheelchair != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.accessible,
                        size: 16,
                        color: p.wheelchair == 'yes'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.wheelchairAccess}: '
                        '${_wheelchairLabel(l10n, p.wheelchair)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n.dataSource,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (p.phone != null && p.phone!.isNotEmpty) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _directions.callPhone(p.phone!),
                    icon: const Icon(Icons.phone),
                    label: Text(l10n.call),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.directions),
                  label: Text(l10n.getDirections),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? actionTooltip;
  final IconData trailingIcon;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.onLongPress,
    this.actionTooltip,
    this.trailingIcon = Icons.content_copy,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            trailingIcon,
            size: 16,
            color: Theme.of(context).hintColor,
          ),
      ],
    );

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: actionTooltip == null
          ? row
          : Tooltip(message: actionTooltip!, child: row),
    );
  }
}
