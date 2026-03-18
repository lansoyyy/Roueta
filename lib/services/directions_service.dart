import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/bus_route.dart';
import 'firestore_service.dart';

/// Fetches road-following polylines from the Google Directions API.
/// Uses a two-level cache: in-memory → Firestore → API call.
class DirectionsService {
  static final DirectionsService _instance = DirectionsService._internal();
  factory DirectionsService() => _instance;
  DirectionsService._internal();

  static const String _apiKey = 'AIzaSyBwByaaKz7j4OGnwPDxeMdmQ4Pa50GA42o';
  static const int _maxWaypoints = 8;

  final PolylinePoints _polylinePoints = PolylinePoints();

  // In-memory cache so we don't re-fetch in the same session.
  final Map<String, List<LatLng>> _memCache = {};

  /// Returns road-following polyline for the given variant.
  /// Priority: memory cache → Firestore cache → Directions API.
  Future<List<LatLng>> getPolylineForVariant(
    String routeId,
    String variantId,
    List<BusStop> stops,
  ) async {
    if (stops.length < 2) return stops.map((s) => s.position).toList();

    final key = '${routeId}_$variantId';

    // 1. Memory cache
    if (_memCache.containsKey(key)) return _memCache[key]!;

    // 2. Firestore cache
    final cached = await FirestoreService().getCachedPolyline(
      routeId,
      variantId,
    );
    if (cached != null && cached.length > 1) {
      _memCache[key] = cached;
      return cached;
    }

    // 3. Directions API
    final points = await _fetchFromDirectionsApi(stops);
    final result = points.isNotEmpty
        ? points
        : stops.map((s) => s.position).toList(); // straight-line fallback

    _memCache[key] = result;

    // Cache in Firestore asynchronously (don't await)
    if (points.isNotEmpty) {
      FirestoreService().cachePolyline(routeId, variantId, result);
    }

    return result;
  }

  Future<List<LatLng>> _fetchFromDirectionsApi(List<BusStop> stops) async {
    try {
      final origin = stops.first.position;
      final destination = stops.last.position;

      // Build waypoints — sample stops to stay within API limits.
      final List<PolylineWayPoint> wayPoints = [];
      if (stops.length > 2) {
        final intermediates = stops.sublist(1, stops.length - 1);
        final step = (intermediates.length / _maxWaypoints).ceil().clamp(1, 99);
        for (int i = 0; i < intermediates.length; i += step) {
          final s = intermediates[i];
          wayPoints.add(
            PolylineWayPoint(
              location: '${s.position.latitude},${s.position.longitude}',
              stopOver: false,
            ),
          );
        }
      }

      final result = await _polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _apiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
          wayPoints: wayPoints,
        ),
      );

      if (result.points.isEmpty) return [];

      return result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } catch (_) {
      return [];
    }
  }

  void invalidateCache(String routeId, String variantId) {
    _memCache.remove('${routeId}_$variantId');
  }
}
