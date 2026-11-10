import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/pharmacy.dart';

/// Local favorites + recent search queries.
class FavoritesService extends ChangeNotifier {
  static const _kFavorites = 'favorites_v1';
  static const _kRecent = 'recent_searches_v1';
  static const _maxRecent = 12;

  final Map<String, Pharmacy> _favorites = {};
  List<String> _recent = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<Pharmacy> get favorites {
    final list = _favorites.values.toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  List<String> get recentSearches => List.unmodifiable(_recent);

  bool isFavorite(String id) => _favorites.containsKey(id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kFavorites);
    _favorites.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = json.decode(raw) as List<dynamic>;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final p = Pharmacy.fromJson(item);
            _favorites[p.id] = p;
          } else if (item is Map) {
            final p = Pharmacy.fromJson(Map<String, dynamic>.from(item));
            _favorites[p.id] = p;
          }
        }
      } catch (e) {
        debugPrint('[FavoritesService] failed to load: $e');
      }
    }
    _recent = prefs.getStringList(_kRecent) ?? [];
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(Pharmacy pharmacy) async {
    if (_favorites.containsKey(pharmacy.id)) {
      _favorites.remove(pharmacy.id);
    } else {
      _favorites[pharmacy.id] = pharmacy;
    }
    notifyListeners();
    await _persistFavorites();
  }

  Future<void> remove(String id) async {
    _favorites.remove(id);
    notifyListeners();
    await _persistFavorites();
  }

  Future<void> addRecentSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    _recent.removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    _recent.insert(0, q);
    if (_recent.length > _maxRecent) {
      _recent = _recent.sublist(0, _maxRecent);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kRecent, _recent);
  }

  Future<void> clearRecent() async {
    _recent = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecent);
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _favorites.values.map((p) => p.toJson()).toList();
    await prefs.setString(_kFavorites, json.encode(list));
  }
}
