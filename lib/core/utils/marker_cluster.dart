import 'package:latlong2/latlong.dart';

import '../../models/pharmacy.dart';

/// Simple geographic grid clustering for map markers.
///
/// At high zoom every pharmacy is its own cluster of size 1.
/// At lower zoom nearby points merge into count badges.
class MarkerCluster {
  final LatLng center;
  final List<Pharmacy> pharmacies;

  const MarkerCluster({required this.center, required this.pharmacies});

  bool get isSingle => pharmacies.length == 1;
  Pharmacy get first => pharmacies.first;
  int get count => pharmacies.length;
}

/// Cluster [pharmacies] using a lat/lng grid sized by [zoom].
List<MarkerCluster> clusterPharmacies(
  List<Pharmacy> pharmacies, {
  required double zoom,
}) {
  if (pharmacies.isEmpty) return const [];

  // Below ~13: coarser cells; 15+: no clustering.
  if (zoom >= 15) {
    return pharmacies
        .map((p) => MarkerCluster(center: p.location, pharmacies: [p]))
        .toList();
  }

  // Cell size in degrees (rough): ~0.01° ≈ 1 km.
  final cell = zoom >= 14
      ? 0.003
      : zoom >= 13
          ? 0.006
          : zoom >= 12
              ? 0.012
              : 0.02;

  final buckets = <String, List<Pharmacy>>{};
  for (final p in pharmacies) {
    final i = (p.location.latitude / cell).floor();
    final j = (p.location.longitude / cell).floor();
    final key = '$i:$j';
    buckets.putIfAbsent(key, () => []).add(p);
  }

  return buckets.values.map((list) {
    if (list.length == 1) {
      return MarkerCluster(center: list.first.location, pharmacies: list);
    }
    var lat = 0.0;
    var lng = 0.0;
    for (final p in list) {
      lat += p.location.latitude;
      lng += p.location.longitude;
    }
    final n = list.length;
    return MarkerCluster(
      center: LatLng(lat / n, lng / n),
      pharmacies: list,
    );
  }).toList();
}
