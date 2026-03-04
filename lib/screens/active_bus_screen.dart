import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/bus_route.dart';
import '../providers/app_provider.dart';

class ActiveBusScreen extends StatefulWidget {
  final BusRoute route;
  const ActiveBusScreen({super.key, required this.route});

  @override
  State<ActiveBusScreen> createState() => _ActiveBusScreenState();
}

class _ActiveBusScreenState extends State<ActiveBusScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  int _currentStopIdx = 0;
  int _minutesToNext = 2;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _buildMapElements();
    _startSimulation();
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
      markers.add(
        Marker(
          markerId: MarkerId(stop.id),
          position: stop.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == _currentStopIdx
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
      color: AppColors.primaryDark,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    setState(() {
      _markers = markers;
      _polylines = {polyline};
    });
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {
        if (_minutesToNext > 1) {
          _minutesToNext--;
        } else {
          // Advance to next stop
          if (_currentStopIdx + 1 < widget.route.stops.length) {
            _currentStopIdx++;
            _minutesToNext = 3;
            _buildMapElements(); // refresh markers
          }
        }
      });
    });
  }

  BusStop? get _nextStop {
    if (_currentStopIdx + 1 < widget.route.stops.length) {
      return widget.route.stops[_currentStopIdx + 1];
    }
    return widget.route.stops.last;
  }

  LatLng get _mapCenter {
    final pts = widget.route.polylinePoints;
    if (pts.isEmpty) return const LatLng(7.0644, 125.5214);
    double lat = 0, lng = 0;
    for (final p in pts) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / pts.length, lng / pts.length);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: Column(
        children: [
          // Top app bar
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              bottom: 10,
              left: 12,
              right: 12,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(child: _SearchBar()),
              ],
            ),
          ),

          // "THE BUS YOU ARE OPERATING" banner
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'THE BUS YOU ARE OPERATING',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),

          // Route info card
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.route.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.route.code,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusOperating,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Operating',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
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
                ),

                // Approaching notification
                Positioned(
                  bottom: 16,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.route.code,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Approaching ${_nextStop?.name ?? "Next Stop"} in $_minutesToNext mins',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Occupancy status buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UPDATE OCCUPANCY STATUS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _OccupancyBtn(
                        label: 'Seat Available',
                        color: AppColors.statusOperating,
                        isSelected:
                            provider.driverOccupancy ==
                            OccupancyStatus.seatAvailable,
                        onTap: () => provider.updateOccupancy(
                          OccupancyStatus.seatAvailable,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _OccupancyBtn(
                        label: 'Limited Seats',
                        color: AppColors.accent,
                        isSelected:
                            provider.driverOccupancy ==
                            OccupancyStatus.limitedSeats,
                        onTap: () => provider.updateOccupancy(
                          OccupancyStatus.limitedSeats,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _OccupancyBtn(
                        label: 'Full Sitting and Standing Capacity',
                        color: AppColors.statusUnavailable,
                        isSelected:
                            provider.driverOccupancy ==
                            OccupancyStatus.fullCapacity,
                        onTap: () => provider.updateOccupancy(
                          OccupancyStatus.fullCapacity,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'ROUTES',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OccupancyBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _OccupancyBtn({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          SizedBox(width: 12),
          Icon(Icons.search, color: Colors.white70, size: 18),
          SizedBox(width: 6),
          Text(
            'SEARCH',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
