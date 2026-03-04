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

  OccupancyStatus _routeOccupancy = OccupancyStatus.limitedSeats;
  DateTime _occupancyLastUpdated =
      DateTime.now().subtract(const Duration(minutes: 8));

  @override
  void initState() {
    super.initState();
    _buildMapElements();
    _simulateApproach();
    final activeRoute = widget.route;
    if (activeRoute.occupancyStatus != null) {
      _routeOccupancy = activeRoute.occupancyStatus!;
      _occupancyLastUpdated =
          activeRoute.occupancyLastUpdated ?? DateTime.now();
    }
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
    for (int i = 0; i < route.stops.length; i++) {
      final stop = route.stops[i];
      markers.add(Marker(
        markerId: MarkerId(stop.id),
        position: stop.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          i == 0 || i == route.stops.length - 1
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueCyan,
        ),
        infoWindow: InfoWindow(title: stop.name),
      ));
    }
    final polyline = Polyline(
      polylineId: PolylineId(route.id),
      points: route.polylinePoints,
      color: const Color(0xFF3F51B5),
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
    setState(() {
      _markers = markers;
      _polylines = {polyline};
      _nearestStop =
          route.stops.length > 1 ? route.stops[1] : route.stops[0];
    });
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
      if (_nearestMinutes == 2 && !_notificationSent && _nearestStop != null)
 {
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
    for (final p in pts) { lat += p.latitude; lng += p.longitude; }
    return LatLng(lat / pts.length, lng / pts.length);
  }

  String get _occupancyLabel {
    switch (_routeOccupancy) {
      case OccupancyStatus.seatAvailable: return '30% Full';
      case OccupancyStatus.limitedSeats: return '80% Full';
      case OccupancyStatus.fullCapacity: return '100% Full';
    }
  }

  int get _occupancyFilled {
    switch (_routeOccupancy) {
      case OccupancyStatus.seatAvailable: return 3;
      case OccupancyStatus.limitedSeats: return 8;
      case OccupancyStatus.fullCapacity: return 10;
    }
  }

  int get _staleMinutes =>
      DateTime.now().difference(_occupancyLastUpdated).inMinutes;
  bool get _isStale => _staleMinutes >= 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _mapCenter, zoom: 13.5),
            onMapCreated: (ctrl) => _mapController = ctrl,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled:
                context.read<AppProvider>().locationPermissionGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top bar
          SafeArea(
            child: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.menu, color: Colors.white, size: 
28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 12),
                          Icon(Icons.search, color: Colors.white70, size: 20)
,
                          SizedBox(width: 8),
                          Text('SEARCH',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ESTIMATED card (top-left of map)
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 12,
            child: _EstimatedCard(
              etaMinutes: _nearestMinutes,
              occupancyLabel: _occupancyLabel,
              occupancyFilled: _occupancyFilled,
              isStale: _isStale,
              staleMinutes: _staleMinutes,
            ),
          ),

          // Route info card (top-right of map)
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            right: 12,
            child: _RouteInfoCard(
              route: widget.route,
              nearestStop: _nearestStop,
              nearestMinutes: _nearestMinutes,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: SafeArea(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.location_on, color: Colors.white, size: 18),      
                SizedBox(width: 6),
                Text('ROUTES',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//  ESTIMATED Card
class _EstimatedCard extends StatelessWidget {
  final int etaMinutes;
  final String occupancyLabel;
  final int occupancyFilled;
  final bool isStale;
  final int staleMinutes;

  const _EstimatedCard({
    required this.etaMinutes,
    required this.occupancyLabel,
    required this.occupancyFilled,
    required this.isStale,
    required this.staleMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 168,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF4DD0E1), width: 2),    
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ESTIMATED badge
              Transform.translate(
                offset: const Offset(0, -12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3)
,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.red.shade400, width: 1.5
),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('ESTIMATED',
                      style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ETA row
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 22, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(': $etaMinutes mins',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Occupancy row
                    Row(
                      children: [
                        const Icon(Icons.airline_seat_recline_extra,
                            size: 22, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(': $occupancyLabel',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Bar
                    _OccupancyBar(filled: occupancyFilled),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isStale) ...[
          const SizedBox(height: 6),
          _NoticeCard(staleMinutes: staleMinutes),
        ],
      ],
    );
  }
}

//  Occupancy Bar
class _OccupancyBar extends StatelessWidget {
  final int filled;
  const _OccupancyBar({required this.filled});

  Color _colorForIndex(int i) {
    if (i < 5) return const Color(0xFF4CAF50);
    if (i < 8) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (i) {
        final active = i < filled;
        return Container(
          width: 12,
          height: 16,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: active ? _colorForIndex(i) : Colors.grey.shade200,        
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

//  NOTICE Card
class _NoticeCard extends StatelessWidget {
  final int staleMinutes;
  const _NoticeCard({required this.staleMinutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),   
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NOTICE',
                    style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(
                  'Occupancy Status was last updated $staleMinutes mins ago, capacity may vary.',
                  style:
                      TextStyle(color: Colors.red.shade700, fontSize: 10),   
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  Route Info Card
class _RouteInfoCard extends StatelessWidget {
  final BusRoute route;
  final BusStop? nearestStop;
  final int nearestMinutes;
  const _RouteInfoCard(
      {required this.route, this.nearestStop, required this.nearestMinutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 155),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.directions_bus,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(route.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          if (nearestStop != null) ...[
            const Divider(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 13), 
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${nearestStop!.name}\n($nearestMinutes mins)',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
