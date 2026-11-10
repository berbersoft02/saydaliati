import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../core/services/directions_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/overpass_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/pharmacy.dart';
import '../../widgets/pharmacy_card.dart';
import '../pharmacy_details/pharmacy_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final Position? userPosition;
  const SearchScreen({super.key, this.userPosition});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _overpass = OverpassService();
  final _directions = const DirectionsService();
  Timer? _debounce;
  List<Pharmacy> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    setState(() {}); // refresh clear button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(q);
    });
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _overpass.searchByText(
        q,
        latitude: widget.userPosition?.latitude,
        longitude: widget.userPosition?.longitude,
      );
      if (!mounted) return;
      context.read<FavoritesService>().addRecentSearch(q);
      setState(() => _results = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onDirections(Pharmacy p) async {
    final ok = await _directions.openDirections(p);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).noMapsApp)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favorites = context.watch<FavoritesService>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
          onSubmitted: _search,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _onChanged('');
              },
            ),
        ],
      ),
      body: _buildBody(l10n, favorites),
    );
  }

  Widget _buildBody(AppLocalizations l10n, FavoritesService favorites) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorOccurred),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _search(_controller.text),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }
    if (_controller.text.isEmpty) {
      final recent = favorites.recentSearches;
      if (recent.isEmpty) {
        return Center(
          child: Text(
            l10n.searchHint,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        );
      }
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  l10n.recentSearches,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => favorites.clearRecent(),
                  child: Text(l10n.clearRecent),
                ),
              ],
            ),
          ),
          ...recent.map(
            (q) => ListTile(
              leading: const Icon(Icons.history),
              title: Text(q),
              onTap: () {
                _controller.text = q;
                _search(q);
              },
            ),
          ),
        ],
      );
    }
    if (_results.isEmpty) {
      return Center(child: Text(l10n.noResults));
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final p = _results[i];
        return PharmacyCard(
          pharmacy: p,
          isFavorite: favorites.isFavorite(p.id),
          onFavoriteToggle: () => favorites.toggle(p),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PharmacyDetailsScreen(
                  pharmacy: p,
                  userPosition: widget.userPosition,
                ),
              ),
            );
          },
          onDirections: () => _onDirections(p),
        );
      },
    );
  }
}
