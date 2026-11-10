import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../core/config/app_config.dart';
import '../core/services/opening_hours_service.dart';

/// Opening status shown in the UI.
enum OpenStatus {
  open,
  closed,
  alwaysOpen,
  unknown,
}

/// A pharmacy on the map, normalised from Overpass API.
class Pharmacy {
  final String id;
  final String osmType;
  final String name;
  final String address;
  final LatLng location;
  final double? distanceMeters;
  final String? phone;
  final String? website;
  final String? operator;
  final String? openingHoursRaw;
  final List<String> openingHours;
  final String? wheelchair;
  final bool isOnDuty;
  final Map<String, String> tags;
  final DateTime? fetchedAt;

  const Pharmacy({
    required this.id,
    this.osmType = 'node',
    required this.name,
    required this.address,
    required this.location,
    this.distanceMeters,
    this.phone,
    this.website,
    this.operator,
    this.openingHoursRaw,
    this.openingHours = const [],
    this.wheelchair,
    this.isOnDuty = false,
    this.tags = const {},
    this.fetchedAt,
  });

  /// Live-evaluated opening status, computed from [openingHoursRaw] at the
  /// current wall-clock time. Replaces the old `openStatus` field so that
  /// a pharmacy cached at 18:00 doesn't still say "open" at 19:00.
  OpenStatus get openStatus {
    if (openingHoursRaw == null) return OpenStatus.unknown;
    if (openingHoursRaw!.trim().toLowerCase() == '24/7') {
      return OpenStatus.alwaysOpen;
    }
    return switch (_hoursService.evaluate(openingHoursRaw)) {
      OpenEvaluation.alwaysOpen => OpenStatus.alwaysOpen,
      OpenEvaluation.open => OpenStatus.open,
      OpenEvaluation.closed => OpenStatus.closed,
      OpenEvaluation.unknown => OpenStatus.unknown,
    };
  }

  static const OpeningHoursService _hoursService = OpeningHoursService();

  bool get isOpen => openStatus == OpenStatus.open || openStatus == OpenStatus.alwaysOpen;

  bool get alwaysOpen => openStatus == OpenStatus.alwaysOpen;

  bool get openNow => openStatus == OpenStatus.open || alwaysOpen;

  /// Build a Pharmacy from a single Overpass 'node' or 'way' element.
  factory Pharmacy.fromOverpass(
    Map<String, dynamic> element, {
    double? userLat,
    double? userLng,
    DateTime? now,
    OpeningHoursService hoursService = const OpeningHoursService(),
  }) {
    final tags = (element['tags'] as Map?)?.cast<String, dynamic>() ?? {};
    final id = (element['id'] as num).toString();
    final osmType = (element['type'] as String?) ?? 'node';

    // Coordinates: nodes have lat/lng directly; ways/relations have a 'center'.
    final center = element['center'] as Map?;
    final lat = (center?['lat'] as num?)?.toDouble() ??
        (element['lat'] as num?)?.toDouble() ??
        0.0;
    final lng = (center?['lon'] as num?)?.toDouble() ??
        (element['lon'] as num?)?.toDouble() ??
        0.0;

    final name = (tags['name'] ??
            tags['name:fr'] ??
            tags['name:ar'] ??
            tags['name:en'] ??
            AppConfig.defaultPharmacyName)
        .toString();

    final street = tags['addr:street']?.toString();
    final house = tags['addr:housenumber']?.toString();
    final city = tags['addr:city']?.toString();
    final addrParts = <String>[
      if (house != null && street != null) '$house $street',
      if (house == null && street != null) street,
      if (city != null) city,
    ];
    final address = addrParts.join(', ').trim().isNotEmpty
        ? addrParts.join(', ')
        : (tags['addr:full']?.toString() ?? '');

    final phone =
        tags['phone']?.toString() ?? tags['contact:phone']?.toString();
    final website =
        tags['website']?.toString() ?? tags['contact:website']?.toString();
    final operator = tags['operator']?.toString();

    final oh = tags['opening_hours']?.toString();
    final openingHours = oh != null ? [oh] : <String>[];

    // "Pharmacie de garde" only when OSM tags clearly suggest duty pharmacy.
    final description = tags['description']?.toString().toLowerCase() ?? '';
    final nameLower = name.toLowerCase();
    final isOnDuty = tags['pharmacy']?.toString().toLowerCase() == 'duty' ||
        description.contains('garde') ||
        nameLower.contains('de garde') ||
        nameLower.contains('garde');

    double? distance;
    if (userLat != null && userLng != null && lat != 0.0 && lng != 0.0) {
      distance = haversineDistance(userLat, userLng, lat, lng);
    }

    return Pharmacy(
      id: id,
      osmType: osmType,
      name: name,
      address: address,
      location: LatLng(lat, lng),
      distanceMeters: distance,
      phone: phone,
      website: website,
      operator: operator,
      openingHoursRaw: oh,
      openingHours: openingHours,
      wheelchair: tags['wheelchair']?.toString(),
      isOnDuty: isOnDuty,
      tags: tags.map((k, v) => MapEntry(k, v.toString())),
      fetchedAt: now ?? DateTime.now(),
    );
  }

  Pharmacy copyWith({
    double? distanceMeters,
  }) {
    return Pharmacy(
      id: id,
      osmType: osmType,
      name: name,
      address: address,
      location: location,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      phone: phone,
      website: website,
      operator: operator,
      openingHoursRaw: openingHoursRaw,
      openingHours: openingHours,
      wheelchair: wheelchair,
      isOnDuty: isOnDuty,
      tags: tags,
      fetchedAt: fetchedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'osmType': osmType,
        'name': name,
        'address': address,
        'lat': location.latitude,
        'lng': location.longitude,
        'phone': phone,
        'website': website,
        'operator': operator,
        'openingHoursRaw': openingHoursRaw,
        'wheelchair': wheelchair,
        'isOnDuty': isOnDuty,
      };

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    final oh = json['openingHoursRaw'] as String?;
    return Pharmacy(
      id: json['id'] as String,
      osmType: (json['osmType'] as String?) ?? 'node',
      name: (json['name'] as String?) ?? AppConfig.defaultPharmacyName,
      address: (json['address'] as String?) ?? '',
      location: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      operator: json['operator'] as String?,
      openingHoursRaw: oh,
      openingHours: oh != null ? [oh] : const [],
      wheelchair: json['wheelchair'] as String?,
      isOnDuty: json['isOnDuty'] as bool? ?? false,
    );
  }

  /// Great-circle distance in meters between two coordinates.
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180.0;
}
