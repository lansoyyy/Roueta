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
  static const int _polylineCacheVersion = 3;

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

    final key = _cacheKey(routeId, variantId);

    // 1. Memory cache
    if (_memCache.containsKey(key)) return _memCache[key]!;

    // 2. Firestore cache
    final cached = await FirestoreService().getCachedPolyline(
      routeId,
      variantId,
      cacheVersion: _polylineCacheVersion,
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
      FirestoreService().cachePolyline(
        routeId,
        variantId,
        result,
        cacheVersion: _polylineCacheVersion,
      );
    }

    return result;
  }

  Future<List<LatLng>> _fetchFromDirectionsApi(List<BusStop> stops) async {
    try {
      final segmentFutures = <Future<List<LatLng>>>[];
      for (int index = 0; index < stops.length - 1; index++) {
        segmentFutures.add(
          _fetchSegmentPolyline(stops[index], stops[index + 1]),
        );
      }

      final segmentResults = await Future.wait(segmentFutures);
      final stitchedPoints = <LatLng>[];

      for (int index = 0; index < segmentResults.length; index++) {
        final fromStop = stops[index];
        final toStop = stops[index + 1];
        final segmentPoints = segmentResults[index];

        if (segmentPoints.isEmpty) {
          _appendUniquePoints(
            stitchedPoints,
            [fromStop.position, toStop.position],
          );
          continue;
        }

        _appendUniquePoints(stitchedPoints, segmentPoints);
      }

      return stitchedPoints;
    } catch (_) {
      return [];
    }
  }

  Future<List<LatLng>> _fetchSegmentPolyline(BusStop fromStop, BusStop toStop) async {
    final origin = fromStop.position;
    final destination = toStop.position;

    final result = await _polylinePoints
        .getRouteBetweenCoordinates(
          googleApiKey: _apiKey,
          request: PolylineRequest(
            origin: PointLatLng(origin.latitude, origin.longitude),
            destination: PointLatLng(
              destination.latitude,
              destination.longitude,
            ),
            mode: TravelMode.driving,
          ),
        )
        .timeout(const Duration(seconds: 6), onTimeout: () {
          return PolylineResult(points: const <PointLatLng>[]);
        });

    if (result.points.isEmpty) {
      return [origin, destination];
    }

    final segmentPoints = result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);

    if (segmentPoints.isEmpty) {
      return [origin, destination];
    }

    final normalizedPoints = <LatLng>[origin];
    _appendUniquePoints(normalizedPoints, segmentPoints);
    _appendUniquePoints(normalizedPoints, [destination]);
    return normalizedPoints;
  }

  void _appendUniquePoints(List<LatLng> target, List<LatLng> points) {
    for (final point in points) {
      if (target.isNotEmpty && _isSamePoint(target.last, point)) {
        continue;
      }
      target.add(point);
    }
  }

  bool _isSamePoint(LatLng a, LatLng b) {
    return a.latitude == b.latitude && a.longitude == b.longitude;
  }

  String _cacheKey(String routeId, String variantId) {
    return 'v${_polylineCacheVersion}_${routeId}_$variantId';
  }

  void invalidateCache(String routeId, String variantId) {
    _memCache.remove(_cacheKey(routeId, variantId));
  }
}
