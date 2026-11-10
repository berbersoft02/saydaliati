import 'package:flutter/material.dart';

import '../core/services/location_service.dart';
import '../l10n/app_localizations.dart';
import '../models/pharmacy.dart';

/// Compact list card showing pharmacy summary.
class PharmacyCard extends StatelessWidget {
  final Pharmacy pharmacy;
  final VoidCallback onTap;
  final VoidCallback onDirections;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool dense;

  const PharmacyCard({
    super.key,
    required this.pharmacy,
    required this.onTap,
    required this.onDirections,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = statusLabel(pharmacy, l10n);
    final statusColor = statusColorFor(pharmacy.openStatus);
    final displayName = pharmacy.name == 'Pharmacy'
        ? l10n.unnamedPharmacy
        : pharmacy.name;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: dense ? 0 : 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(dense ? 10 : 12),
          child: Row(
            children: [
              _Avatar(status: pharmacy.openStatus),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (pharmacy.address.isNotEmpty)
                      Text(
                        pharmacy.address,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _StatusChip(
                          label: status,
                          color: statusColor.withValues(alpha: 0.15),
                          textColor: statusColor,
                        ),
                        if (pharmacy.isOnDuty)
                          _StatusChip(
                            label: l10n.pharmacyOnDuty,
                            color: theme.colorScheme.tertiaryContainer,
                            textColor: theme.colorScheme.onTertiaryContainer,
                            icon: Icons.nightlight_round,
                          ),
                        if (pharmacy.distanceMeters != null)
                          _StatusChip(
                            label: LocationService.formatDistance(
                              pharmacy.distanceMeters!,
                            ),
                            color: theme.colorScheme.secondaryContainer,
                            textColor: theme.colorScheme.onSecondaryContainer,
                            icon: Icons.near_me,
                          ),
                        if (pharmacy.wheelchair == 'yes')
                          _StatusChip(
                            label: l10n.wheelchairYes,
                            color: theme.colorScheme.primaryContainer,
                            textColor: theme.colorScheme.onPrimaryContainer,
                            icon: Icons.accessible,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onFavoriteToggle != null)
                IconButton(
                  tooltip: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : null,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              IconButton(
                tooltip: l10n.getDirections,
                icon: const Icon(Icons.directions),
                color: theme.colorScheme.primary,
                onPressed: onDirections,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String statusLabel(Pharmacy p, AppLocalizations l10n) {
    switch (p.openStatus) {
      case OpenStatus.alwaysOpen:
        return l10n.open24h;
      case OpenStatus.open:
        return l10n.openNow;
      case OpenStatus.closed:
        return l10n.closed;
      case OpenStatus.unknown:
        return l10n.hoursUnknown;
    }
  }

  static Color statusColorFor(OpenStatus status) {
    switch (status) {
      case OpenStatus.alwaysOpen:
        return Colors.teal;
      case OpenStatus.open:
        return Colors.green.shade700;
      case OpenStatus.closed:
        return Colors.red.shade700;
      case OpenStatus.unknown:
        return Colors.grey.shade600;
    }
  }
}

class _Avatar extends StatelessWidget {
  final OpenStatus status;
  const _Avatar({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = switch (status) {
      OpenStatus.alwaysOpen => Colors.teal,
      OpenStatus.open => Colors.green,
      OpenStatus.closed => Colors.red,
      OpenStatus.unknown => Colors.grey,
    };
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? c.withValues(alpha: 0.25) : c.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c, width: 1.5),
      ),
      child: Icon(
        Icons.local_pharmacy,
        color: isDark ? c.shade200 : c.shade700,
        size: 26,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final IconData? icon;

  const _StatusChip({
    required this.label,
    required this.color,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
