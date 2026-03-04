import 'package:google_maps_flutter/google_maps_flutter.dart';

enum RouteStatus { operating, onStandby, unavailable }

enum OccupancyStatus { seatAvailable, limitedSeats, fullCapacity }

class BusStop {
  final String id;
  final String name;
  final LatLng position;
  final int? estimatedMinutesFromStart;

  const BusStop({
    required this.id,
    required this.name,
    required this.position,
    this.estimatedMinutesFromStart,
  });
}

class BusRoute {
  final String id;
  final String name;
  final String code;
  final String origin;
  final String destination;
  final String amStartTime;
  final String amEndTime;
  final String pmStartTime;
  final String pmEndTime;
  final List<BusStop> stops;
  final List<LatLng> polylinePoints;
  RouteStatus status;
  OccupancyStatus? occupancyStatus;
  DateTime? occupancyLastUpdated;
  int currentStopIndex;

  BusRoute({
    required this.id,
    required this.name,
    required this.code,
    required this.origin,
    required this.destination,
    required this.amStartTime,
    required this.amEndTime,
    required this.pmStartTime,
    required this.pmEndTime,
    required this.stops,
    required this.polylinePoints,
    this.status = RouteStatus.onStandby,
    this.occupancyStatus,
    this.occupancyLastUpdated,
    this.currentStopIndex = 0,
  });

  LatLng get startPosition => stops.first.position;
  LatLng get endPosition => stops.last.position;

  BusStop? get currentStop => stops.isNotEmpty ? stops[currentStopIndex] : null;

  BusStop? get nextStop =>
      currentStopIndex + 1 < stops.length ? stops[currentStopIndex + 1] : null;
}
