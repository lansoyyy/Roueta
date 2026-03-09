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
  final String? initialVariantId;

  const RouteMapScreen({super.key, required this.route, this.initialVariantId});

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
  late String _variantId;

  OccupancyStatus _routeOccupancy = OccupancyStatus.limitedSeats;
  DateTime _occupancyLastUpdated = DateTime.now().subtract(
    const Duration(minutes: 8),
  );

  RouteVariant get _variant =>
      widget.route.variantById(_variantId) ?? widget.route.defaultVariant;

  List<BusStop> get _stops => _variant.stops;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _variantId =
        widget.initialVariantId ??
        provider.selectedVariantId ??
        widget.route.defaultVariantId;
    widget.route.selectVariant(_variantId);

    if (widget.route.occupancyStatus != null) {
      _routeOccupancy = widget.route.occupancyStatus!;
      _occupancyLastUpdated =
          widget.route.occupancyLastUpdated ?? DateTime.now();
    }

    _buildMapElements();
    _simulateApproach();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _changeVariant(String newVariantId) {
    setState(() {
      _variantId = newVariantId;
      widget.route.selectVariant(newVariantId);
      _nearestMinutes = 2;
      _notificationSent = false;
    });

    context.read<AppProvider>().selectRoute(
      widget.route,
      variantId: newVariantId,
    );
    _buildMapElements();
  }

  void _buildMapElements() {
    if (_stops.isEmpty) return;

    final markers = <Marker>{};

    for (int i = 0; i < _stops.length; i++) {
      final stop = _stops[i];
      markers.add(
        Marker(
          markerId: MarkerId(stop.id),
          position: stop.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 || i == _stops.length - 1
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueCyan,
          ),
          infoWindow: InfoWindow(title: stop.name),
        ),
      );
    }

    final polyline = Polyline(
      polylineId: PolylineId('${widget.route.id}_${_variant.id}'),
      points: _variant.polylinePoints,
      color: const Color(0xFF3F51B5),
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    setState(() {
      _markers = markers;
      _polylines = {polyline};
      _nearestStop = _stops.length > 1 ? _stops[1] : _stops.first;
    });
  }

  void _simulateApproach() {
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted || _stops.isEmpty || _nearestStop == null) return;

      setState(() {
        if (_nearestMinutes > 1) {
          _nearestMinutes--;
        } else {
          final idx = _stops.indexOf(_nearestStop!);
          if (idx + 1 < _stops.length) {
            _nearestStop = _stops[idx + 1];
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
    final pts = _variant.polylinePoints;
    if (pts.isEmpty) return const LatLng(7.0644, 125.5214);

    double lat = 0;
    double lng = 0;
    for (final p in pts) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / pts.length, lng / pts.length);
  }

  String get _occupancyLabel {
    switch (_routeOccupancy) {
      case OccupancyStatus.seatAvailable:
        return 'Seats Available';
      case OccupancyStatus.limitedSeats:
        return 'Limited Seats';
      case OccupancyStatus.fullCapacity:
        return 'Full Capacity';
    }
  }

  Color get _occupancyColor {
    switch (_routeOccupancy) {
      case OccupancyStatus.seatAvailable:
        return AppColors.statusOperating;
      case OccupancyStatus.limitedSeats:
        return AppColors.accent;
      case OccupancyStatus.fullCapacity:
        return AppColors.statusUnavailable;
    }
  }

  int get _staleMinutes =>
      DateTime.now().difference(_occupancyLastUpdated).inMinutes;

  bool get _isStale => _staleMinutes >= 5;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              key: const ValueKey('route_map'),
              initialCameraPosition: CameraPosition(
                target: _mapCenter,
                zoom: 13.5,
              ),
              onMapCreated: (ctrl) => _mapController = ctrl,
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: provider.locationPermissionGranted,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              buildingsEnabled: true,
              compassEnabled: false,
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.route.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryVeryLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.route.code,
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_stops.length} stops',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _variantId,
                  isDense: true,
                  items: widget.route.orderedVariants
                      .map(
                        (v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(v.shortLabel),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) _changeVariant(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Trip Variant',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _nearestStop == null
                      ? 'No stop data available'
                      : 'Approaching ${_nearestStop!.name} in $_nearestMinutes mins',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _occupancyColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _occupancyLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isStale)
                      Text(
                        'Last updated $_staleMinutes mins ago',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
