import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:saydaliati/core/utils/marker_cluster.dart';
import 'package:saydaliati/models/pharmacy.dart';

Pharmacy _p(String id, double lat, double lng) => Pharmacy(
      id: id,
      name: id,
      address: '',
      location: LatLng(lat, lng),
    );

void main() {
  group('clusterPharmacies', () {
    test('high zoom keeps singles', () {
      final list = [_p('1', 36.75, 3.05), _p('2', 36.751, 3.051)];
      final clusters = clusterPharmacies(list, zoom: 16);
      expect(clusters.length, 2);
      expect(clusters.every((c) => c.isSingle), isTrue);
    });

    test('low zoom merges nearby points', () {
      final list = [
        _p('1', 36.75, 3.05),
        _p('2', 36.7505, 3.0505),
        _p('3', 36.8, 3.1),
      ];
      final clusters = clusterPharmacies(list, zoom: 12);
      expect(clusters.length, lessThan(3));
      expect(clusters.any((c) => c.count >= 2), isTrue);
    });
  });
}
