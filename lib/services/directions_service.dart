import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/bus_route.dart';
import 'firestore_service.dart';

/// Fetches road-following polylines from the Google Directions API.
/// Uses a two-level cache: in-memory → Firestore → API call.
class DirectionsService {
  static final DirectionsService _instance = DirectionsService._internal();
  factory DirectionsService() => _instance;
  DirectionsService._internal();

  static const String _apiKey = 'AIzaSyBwByaaKz7j4OGnwPDxeMdmQ4Pa50GA42o';
  static const int _polylineCacheVersion = 5;

  final PolylinePoints _polylinePoints = PolylinePoints();

  // In-memory cache so we don't re-fetch in the same session.
  final Map<String, List<LatLng>> _memCache = {};

  /// Returns road-following polyline for the given variant.
  /// Priority: memory cache → Firestore cache → Directions API.
  Future<List<LatLng>> getPolylineForVariant(
    String routeId,
    RouteVariant variant,
  ) async {
    final variantId = variant.id;
    final routingPoints = variant.polylinePoints.length >= 2
        ? variant.polylinePoints
        : variant.stops.map((stop) => stop.position).toList(growable: false);
    if (routingPoints.length < 2) return const <LatLng>[];

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
    final points = await _fetchFromDirectionsApi(routingPoints);
    final result = points.isNotEmpty
        ? points
        : _hasManualRoutingPath(variant)
        ? routingPoints
        : const <LatLng>[];

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

  Future<List<LatLng>> _fetchFromDirectionsApi(
    List<LatLng> routingPoints,
  ) async {
    try {
      final batchedRequests = _buildRequestBatches(routingPoints);
      final stitchedPoints = <LatLng>[];

      for (final batch in batchedRequests) {
        final batchPoints = await _fetchBatchPolyline(batch);
        if (batchPoints.isEmpty) {
          return await _fetchBySegments(routingPoints);
        }
        _appendUniquePoints(stitchedPoints, batchPoints);
      }

      return stitchedPoints;
    } catch (_) {
      return [];
    }
  }

  List<List<LatLng>> _buildRequestBatches(
    List<LatLng> routingPoints, {
    int maxPointsPerRequest = 25,
  }) {
    if (routingPoints.length <= maxPointsPerRequest) {
      return [routingPoints];
    }

    final batches = <List<LatLng>>[];
    var startIndex = 0;

    while (startIndex < routingPoints.length - 1) {
      final endIndex = math.min(
        startIndex + maxPointsPerRequest - 1,
        routingPoints.length - 1,
      );
      batches.add(routingPoints.sublist(startIndex, endIndex + 1));

      if (endIndex >= routingPoints.length - 1) {
        break;
      }
      startIndex = endIndex;
    }

    return batches;
  }

  Future<List<LatLng>> _fetchBySegments(List<LatLng> routingPoints) async {
    final stitchedPoints = <LatLng>[];

    for (var index = 0; index < routingPoints.length - 1; index++) {
      final segmentPoints = await _fetchBatchPolyline([
        routingPoints[index],
        routingPoints[index + 1],
      ]);
      if (segmentPoints.isEmpty) {
        return [];
      }
      _appendUniquePoints(stitchedPoints, segmentPoints);
    }

    return stitchedPoints;
  }

  Future<List<LatLng>> _fetchBatchPolyline(List<LatLng> batchPoints) async {
    final response = await http
        .get(_buildDirectionsUri(batchPoints))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return [];
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = (body['status'] as String?) ?? '';
    if (status != 'OK') {
      return [];
    }

    final routes = body['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      return [];
    }

    final route = routes.first as Map<String, dynamic>;
    final points = _decodeRouteSteps(route);
    if (points.isEmpty) {
      final overview =
          (route['overview_polyline'] as Map<String, dynamic>?)?['points']
              as String?;
      if (overview == null || overview.isEmpty) {
        return [];
      }

      final overviewPoints = _polylinePoints
          .decodePolyline(overview)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(growable: false);

      if (overviewPoints.isEmpty) {
        return [];
      }

      final normalizedOverview = <LatLng>[batchPoints.first];
      _appendUniquePoints(normalizedOverview, overviewPoints);
      _appendUniquePoints(normalizedOverview, [batchPoints.last]);
      return normalizedOverview;
    }

    final normalizedPoints = <LatLng>[batchPoints.first];
    _appendUniquePoints(normalizedPoints, points);
    _appendUniquePoints(normalizedPoints, [batchPoints.last]);
    return normalizedPoints;
  }

  Uri _buildDirectionsUri(List<LatLng> batchPoints) {
    final params = <String, String>{
      'origin': _pointString(batchPoints.first),
      'destination': _pointString(batchPoints.last),
      'mode': 'driving',
      'units': 'metric',
      'key': _apiKey,
    };

    if (batchPoints.length > 2) {
      params['waypoints'] = batchPoints
          .sublist(1, batchPoints.length - 1)
          .map((point) => 'via:${_pointString(point)}')
          .join('|');
    }

    return Uri.https('maps.googleapis.com', 'maps/api/directions/json', params);
  }

  List<LatLng> _decodeRouteSteps(Map<String, dynamic> route) {
    final decodedPoints = <LatLng>[];
    final legs = route['legs'] as List<dynamic>?;
    if (legs == null) {
      return decodedPoints;
    }

    for (final leg in legs) {
      final steps = (leg as Map<String, dynamic>)['steps'] as List<dynamic>?;
      if (steps == null) {
        continue;
      }

      for (final step in steps) {
        final polyline =
            ((step as Map<String, dynamic>)['polyline']
                    as Map<String, dynamic>?)?['points']
                as String?;
        if (polyline == null || polyline.isEmpty) {
          continue;
        }

        final stepPoints = _polylinePoints
            .decodePolyline(polyline)
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(growable: false);
        _appendUniquePoints(decodedPoints, stepPoints);
      }
    }

    return decodedPoints;
  }

  String _pointString(LatLng point) => '${point.latitude},${point.longitude}';

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

  bool _hasManualRoutingPath(RouteVariant variant) {
    if (variant.polylinePoints.length != variant.stops.length) {
      return true;
    }
    for (int index = 0; index < variant.stops.length; index++) {
      if (!_isSamePoint(
        variant.polylinePoints[index],
        variant.stops[index].position,
      )) {
        return true;
      }
    }
    return false;
  }

  String _cacheKey(String routeId, String variantId) {
    return 'v${_polylineCacheVersion}_${routeId}_$variantId';
  }

  void invalidateCache(String routeId, String variantId) {
    _memCache.remove(_cacheKey(routeId, variantId));
  }
}
