import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/bus_route.dart';
import '../providers/app_provider.dart';
import '../services/notification_service.dart';

class RouteMapScreen extends StatefulWidget {
  final BusRoute route;
  const RouteMapScreen({super.key, required this.route});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  BusStop? _nearestStop;
  int _nearestMinutes = 2;
  bool _notificationSent = false;
  Timer? _timer;
  bool _mapCreated = false;

  OccupancyStatus _routeOccupancy = OccupancyStatus.limitedSeats;
  DateTime _occupancyLastUpdated = DateTime.now().subtract(
    const Duration(minutes: 8),
  );

  @override
  void initState() {
    super.initState();
    print('===== initState called =====');
    print('Route: ${widget.route.name}');
    _simulateApproach();
    final activeRoute = widget.route;
    if (activeRoute.occupancyStatus != null) {
      _routeOccupancy = activeRoute.occupancyStatus!;
      _occupancyLastUpdated =
          activeRoute.occupancyLastUpdated ?? DateTime.now();
    }
    // Build map elements immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('===== Post frame callback =====');
      _buildMapElements();
      // Check if map was created after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_mapCreated) {
          print('ERROR: Google Map failed to load after 5 seconds!');
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _buildMapElements() {
    final markers = <Marker>{};
    final route = widget.route;
    print('Building map elements for route: ${route.name}');
    print('Number of stops: ${route.stops.length}');
    print('Number of polyline points: ${route.polylinePoints.length}');

    for (int i = 0; i < route.stops.length; i++) {
      final stop = route.stops[i];
      print('Adding marker for stop: ${stop.name} at ${stop.position}');
      markers.add(
        Marker(
          markerId: MarkerId(stop.id),
          position: stop.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 || i == route.stops.length - 1
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueCyan,
          ),
          infoWindow: InfoWindow(title: stop.name),
        ),
      );
    }
    final polyline = Polyline(
      polylineId: PolylineId(route.id),
      points: route.polylinePoints,
      color: const Color(0xFF3F51B5),
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
    print('Adding polyline with ${polyline.points.length} points');
    setState(() {
      _markers = markers;
      _polylines = {polyline};
      _nearestStop = route.stops.length > 1 ? route.stops[1] : route.stops[0];
    });
    print('Markers set: ${_markers.length}');
    print('Polylines set: ${_polylines.length}');
  }

  void _simulateApproach() {
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) return;
      setState(() {
        if (_nearestMinutes > 1) {
          _nearestMinutes--;
        } else {
          final idx = widget.route.stops.indexOf(_nearestStop!);
          if (idx + 1 < widget.route.stops.length) {
            _nearestStop = widget.route.stops[idx + 1];
            _nearestMinutes = 4;
            _notificationSent = false;
          }
        }
      });
      if (_nearestMinutes == 2 && !_notificationSent && _nearestStop != null) {
        _notificationSent = true;
        NotificationService().showBusApproachingNotification(
          stopName: _nearestStop!.name,
          minutesAway: 2,
        );
      }
    });
  }

  LatLng get _mapCenter {
    final pts = widget.route.polylinePoints;
    if (pts.isEmpty) return const LatLng(7.0644, 125.5214);
    double lat = 0, lng = 0;
    for (final p in pts) {
      lat += p.latitude;
      lng += p.longitude;
    }
    final center = LatLng(lat / pts.length, lng / pts.length);
    print('Map center calculated: $center');
    print('First point: ${pts.first}, Last point: ${pts.last}');
    return center;
  }

  String get _occupancyLabel {
    switch (_routeOccupancy) {
      case OccupancyStatus.seatAvailable:
        return '30% Full';
      case OccupancyStatus.limitedSeats:
        return '80% Full';
      case OccupancyStatus.fullCapacity:
        return '100% Full';
    }
  }

  int get _occupancyFilled {
    switch (_routeOccupancy) {
      case OccupancyStatus.seatAvailable:
        return 3;
      case OccupancyStatus.limitedSeats:
        return 8;
      case OccupancyStatus.fullCapacity:
        return 10;
    }
  }

  int get _staleMinutes =>
      DateTime.now().difference(_occupancyLastUpdated).inMinutes;
  bool get _isStale => _staleMinutes >= 5;

  @override
  Widget build(BuildContext context) {
    print('Building RouteMapScreen...');
    print('Map center: $_mapCenter');
    print('Map created: $_mapCreated');

    return Scaffold(
      body: GoogleMap(
        key: const ValueKey('route_map'),
        initialCameraPosition: CameraPosition(target: _mapCenter, zoom: 13.5),
        onMapCreated: (ctrl) {
          print('✓✓✓ Map created successfully! ✓✓✓');
          print('✓✓✓ Map controller initialized ✓✓✓');
          _mapController = ctrl;
          _mapCreated = true;
        },
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        buildingsEnabled: true,
        compassEnabled: false,
        rotateGesturesEnabled: true,
        scrollGesturesEnabled: true,
        tiltGesturesEnabled: true,
        zoomGesturesEnabled: true,
      ),
    );
  }
}
