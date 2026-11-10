import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/directions_service.dart';
import '../../core/services/favorites_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/pharmacy_card.dart';
import '../pharmacy_details/pharmacy_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favorites = context.watch<FavoritesService>();
    const directions = DirectionsService();
    final list = favorites.favorites;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites)),
      body: list.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 56,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noFavorites,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final p = list[i];
                return PharmacyCard(
                  pharmacy: p,
                  isFavorite: true,
                  onFavoriteToggle: () => favorites.toggle(p),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PharmacyDetailsScreen(pharmacy: p),
                      ),
                    );
                  },
                  onDirections: () async {
                    final ok = await directions.openDirections(p);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.noMapsApp)),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
