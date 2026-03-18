import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Central Firestore service — all collection reads/writes go through here.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Bus Locations ─────────────────────────────────────────────────────────

  Future<void> updateBusLocation({
    required String driverBadge,
    required String driverName,
    required String routeId,
    required String variantId,
    required double lat,
    required double lng,
    required int currentStopIndex,
  }) async {
    try {
      await _db.collection('bus_locations').doc(driverBadge).set({
        'driverBadge': driverBadge,
        'driverName': driverName,
        'routeId': routeId,
        'variantId': variantId,
        'lat': lat,
        'lng': lng,
        'currentStopIndex': currentStopIndex,
        'isActive': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> clearBusLocation(String driverBadge) async {
    try {
      await _db.collection('bus_locations').doc(driverBadge).set({
        'driverBadge': driverBadge,
        'isActive': false,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Stream<QuerySnapshot> streamActiveBusLocations() {
    return _db
        .collection('bus_locations')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot> streamBusLocationsForRoute(String routeId) {
    return _db
        .collection('bus_locations')
        .where('routeId', isEqualTo: routeId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  // ── Route Status & Occupancy ──────────────────────────────────────────────

  Future<void> updateRouteStatusAndOccupancy({
    required String routeId,
    String? status,
    String? occupancyStatus,
    String? updatedBy,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'routeId': routeId,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
        'lastUpdatedBy': updatedBy ?? 'system',
      };
      if (status != null) data['status'] = status;
      if (occupancyStatus != null) {
        data['occupancyStatus'] = occupancyStatus;
        data['occupancyLastUpdated'] = FieldValue.serverTimestamp();
      }
      await _db
          .collection('route_status')
          .doc(routeId)
          .set(data, SetOptions(merge: true));
    } catch (_) {}
  }

  Stream<QuerySnapshot> streamAllRouteStatuses() {
    return _db.collection('route_status').snapshots();
  }

  // ── Feedback ──────────────────────────────────────────────────────────────

  Future<void> submitFeedback({
    required String category,
    required String subject,
    required String message,
    required int rating,
  }) async {
    await _db.collection('feedback').add({
      'category': category,
      'subject': subject,
      'message': message,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
      'platform': 'android',
      'appVersion': '1.0.0',
    });
  }

  // ── Polyline Cache ────────────────────────────────────────────────────────

  Future<List<LatLng>?> getCachedPolyline(
    String routeId,
    String variantId,
  ) async {
    try {
      final doc = await _db
          .collection('polyline_cache')
          .doc('${routeId}_$variantId')
          .get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      final points = data['points'] as List<dynamic>?;
      if (points == null || points.isEmpty) return null;
      return points.map((p) {
        final map = p as Map<String, dynamic>;
        return LatLng(
          (map['lat'] as num).toDouble(),
          (map['lng'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> cachePolyline(
    String routeId,
    String variantId,
    List<LatLng> points,
  ) async {
    try {
      await _db.collection('polyline_cache').doc('${routeId}_$variantId').set({
        'routeId': routeId,
        'variantId': variantId,
        'points': points
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
        'cachedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ── Driver Accounts ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getDriverAccount(String username) async {
    try {
      final doc = await _db.collection('driver_accounts').doc(username).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  /// Seeds default driver accounts into Firestore if they don't exist.
  Future<void> seedDriverAccounts() async {
    try {
      final accounts = [
        {
          'username': 'driver01',
          'password': 'roueta123',
          'name': 'Juan Dela Cruz',
          'badge': 'BUS-001',
          'assignedRoutes': ['r102', 'r103'],
        },
        {
          'username': 'driver02',
          'password': 'roueta123',
          'name': 'Pedro Santos',
          'badge': 'BUS-002',
          'assignedRoutes': ['r402', 'r403'],
        },
        {
          'username': 'konduktor01',
          'password': 'roueta123',
          'name': 'Maria Garcia',
          'badge': 'BUS-003',
          'assignedRoutes': ['r503', 'r603'],
        },
        {
          'username': 'konduktor02',
          'password': 'roueta123',
          'name': 'Ana Reyes',
          'badge': 'BUS-004',
          'assignedRoutes': ['r763', 'r783'],
        },
        {
          'username': 'admin',
          'password': 'admin123',
          'name': 'Admin Driver',
          'badge': 'BUS-ADM',
          'assignedRoutes': [
            'r102',
            'r103',
            'r402',
            'r403',
            'r503',
            'r603',
            'r763',
            'r783',
            'r793',
          ],
        },
      ];

      final batch = _db.batch();
      for (final acc in accounts) {
        final ref = _db
            .collection('driver_accounts')
            .doc(acc['username'] as String);
        // merge: true so we don't overwrite if already seeded
        batch.set(ref, acc, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (_) {}
  }
}
