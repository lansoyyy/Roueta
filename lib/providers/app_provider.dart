import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus_route.dart';
import '../data/routes_data.dart';

enum UserMode { passenger, driver }

class RecentRouteEntry {
  final String routeId;
  final String routeCode;
  final String routeName;
  final String variantId;
  final String variantLabel;
  final DateTime viewedAt;

  const RecentRouteEntry({
    required this.routeId,
    required this.routeCode,
    required this.routeName,
    required this.variantId,
    required this.variantLabel,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
    'routeId': routeId,
    'routeCode': routeCode,
    'routeName': routeName,
    'variantId': variantId,
    'variantLabel': variantLabel,
    'viewedAt': viewedAt.toIso8601String(),
  };

  static RecentRouteEntry fromJson(Map<String, dynamic> json) {
    return RecentRouteEntry(
      routeId: json['routeId'] as String,
      routeCode: json['routeCode'] as String,
      routeName: json['routeName'] as String,
      variantId: json['variantId'] as String,
      variantLabel: json['variantLabel'] as String,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
    );
  }
}

class DriverTripRecord {
  final String routeId;
  final String routeCode;
  final String routeName;
  final String variantId;
  final String variantLabel;
  final DateTime startedAt;
  final DateTime endedAt;
  final int stopsCompleted;
  final int totalStops;
  final OccupancyStatus? peakOccupancy;

  const DriverTripRecord({
    required this.routeId,
    required this.routeCode,
    required this.routeName,
    required this.variantId,
    required this.variantLabel,
    required this.startedAt,
    required this.endedAt,
    required this.stopsCompleted,
    required this.totalStops,
    required this.peakOccupancy,
  });

  Map<String, dynamic> toJson() => {
    'routeId': routeId,
    'routeCode': routeCode,
    'routeName': routeName,
    'variantId': variantId,
    'variantLabel': variantLabel,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'stopsCompleted': stopsCompleted,
    'totalStops': totalStops,
    'peakOccupancy': peakOccupancy?.name,
  };

  static DriverTripRecord fromJson(Map<String, dynamic> json) {
    final occ = json['peakOccupancy'] as String?;
    return DriverTripRecord(
      routeId: json['routeId'] as String,
      routeCode: json['routeCode'] as String,
      routeName: json['routeName'] as String,
      variantId: json['variantId'] as String,
      variantLabel: json['variantLabel'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      stopsCompleted: json['stopsCompleted'] as int,
      totalStops: json['totalStops'] as int,
      peakOccupancy: occ == null
          ? null
          : OccupancyStatus.values.firstWhere(
              (e) => e.name == occ,
              orElse: () => OccupancyStatus.limitedSeats,
            ),
    );
  }
}

class AppProvider extends ChangeNotifier {
  static const String _recentRoutesKey = 'recent_routes';
  static const String _driverTripsKey = 'driver_trip_history';

  final List<BusRoute> _routes = RoutesData.routes;
  BusRoute? _selectedRoute;
  String? _selectedVariantId;
  UserMode _userMode = UserMode.passenger;
  Position? _currentPosition;
  bool _locationPermissionGranted = false;
  bool _isLoadingLocation = false;
  String _searchQuery = '';
  BusRoute? _activeDriverRoute;
  String? _activeDriverVariantId;
  OccupancyStatus? _driverOccupancy;
  final List<RecentRouteEntry> _recentRoutes = [];
  final List<DriverTripRecord> _driverTripHistory = [];

  DateTime? _activeTripStartedAt;
  int _activeTripMaxStopIndex = 0;
  OccupancyStatus? _activeTripPeakOccupancy;

  // Getters
  List<BusRoute> get routes => _routes;
  BusRoute? get selectedRoute => _selectedRoute;
  String? get selectedVariantId => _selectedVariantId;
  RouteVariant? get selectedRouteVariant {
    if (_selectedRoute == null) return null;
    final id = _selectedVariantId ?? _selectedRoute!.defaultVariantId;
    return _selectedRoute!.variantById(id) ?? _selectedRoute!.defaultVariant;
  }

  UserMode get userMode => _userMode;
  Position? get currentPosition => _currentPosition;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get isLoadingLocation => _isLoadingLocation;
  String get searchQuery => _searchQuery;
  BusRoute? get activeDriverRoute => _activeDriverRoute;
  String? get activeDriverVariantId => _activeDriverVariantId;
  RouteVariant? get activeDriverVariant {
    if (_activeDriverRoute == null) return null;
    final id = _activeDriverVariantId ?? _activeDriverRoute!.defaultVariantId;
    return _activeDriverRoute!.variantById(id) ??
        _activeDriverRoute!.defaultVariant;
  }

  OccupancyStatus? get driverOccupancy => _driverOccupancy;
  List<RecentRouteEntry> get recentRoutes => List.unmodifiable(_recentRoutes);
  List<DriverTripRecord> get driverTripHistory =>
      List.unmodifiable(_driverTripHistory);

  LatLng get currentLatLng => _currentPosition != null
      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
      : const LatLng(7.0644, 125.5214); // Default: Davao City center

  List<BusRoute> get filteredRoutes {
    if (_searchQuery.isEmpty) return _routes;
    final query = _searchQuery.toLowerCase();
    return _routes
        .where(
          (r) =>
              r.name.toLowerCase().contains(query) ||
              r.code.toLowerCase().contains(query) ||
              r.origin.toLowerCase().contains(query) ||
              r.destination.toLowerCase().contains(query) ||
              r.allStopNames.any((s) => s.toLowerCase().contains(query)),
        )
        .toList();
  }

  void setUserMode(UserMode mode) {
    _userMode = mode;
    notifyListeners();
  }

  Future<void> initLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    final recentRaw = prefs.getString(_recentRoutesKey);
    if (recentRaw != null && recentRaw.isNotEmpty) {
      final decoded = jsonDecode(recentRaw) as List<dynamic>;
      _recentRoutes
        ..clear()
        ..addAll(
          decoded
              .map((e) => RecentRouteEntry.fromJson(e as Map<String, dynamic>))
              .toList(growable: false),
        );
    }

    final tripRaw = prefs.getString(_driverTripsKey);
    if (tripRaw != null && tripRaw.isNotEmpty) {
      final decoded = jsonDecode(tripRaw) as List<dynamic>;
      _driverTripHistory
        ..clear()
        ..addAll(
          decoded
              .map((e) => DriverTripRecord.fromJson(e as Map<String, dynamic>))
              .toList(growable: false),
        );
    }

    notifyListeners();
  }

  void selectRoute(BusRoute route, {String? variantId}) {
    _selectedRoute = route;
    _selectedVariantId = variantId ?? route.defaultVariantId;
    route.selectVariant(_selectedVariantId);
    addRecentRoute(route, _selectedVariantId ?? route.defaultVariantId);
    notifyListeners();
  }

  void selectRouteVariant(String variantId) {
    if (_selectedRoute == null) return;
    if (_selectedRoute!.variantById(variantId) == null) return;
    _selectedVariantId = variantId;
    _selectedRoute!.selectVariant(variantId);
    notifyListeners();
  }

  void clearSelectedRoute() {
    _selectedRoute = null;
    _selectedVariantId = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveDriverRoute(BusRoute? route, {String? variantId}) {
    _activeDriverRoute = route;
    _activeDriverVariantId = variantId;
    if (route != null) {
      route.selectVariant(variantId ?? route.defaultVariantId);
      route.status = RouteStatus.operating;
      _activeTripStartedAt = DateTime.now();
      _activeTripMaxStopIndex = 0;
      _activeTripPeakOccupancy = null;
    }
    notifyListeners();
  }

  void updateActiveStopProgress(int stopIndex) {
    if (stopIndex > _activeTripMaxStopIndex) {
      _activeTripMaxStopIndex = stopIndex;
    }
  }

  void stopDriverRoute() {
    if (_activeDriverRoute != null && _activeTripStartedAt != null) {
      final variant = activeDriverVariant;
      final totalStops =
          variant?.stops.length ?? _activeDriverRoute!.stops.length;
      final completedStops = (_activeTripMaxStopIndex + 1).clamp(1, totalStops);

      _driverTripHistory.insert(
        0,
        DriverTripRecord(
          routeId: _activeDriverRoute!.id,
          routeCode: _activeDriverRoute!.code,
          routeName: _activeDriverRoute!.name,
          variantId: variant?.id ?? _activeDriverRoute!.defaultVariantId,
          variantLabel: variant?.shortLabel ?? 'AM • Outbound',
          startedAt: _activeTripStartedAt!,
          endedAt: DateTime.now(),
          stopsCompleted: completedStops,
          totalStops: totalStops,
          peakOccupancy: _activeTripPeakOccupancy ?? _driverOccupancy,
        ),
      );

      if (_driverTripHistory.length > 100) {
        _driverTripHistory.removeRange(100, _driverTripHistory.length);
      }
      _saveDriverTrips();
    }

    if (_activeDriverRoute != null) {
      _activeDriverRoute!.status = RouteStatus.onStandby;
      _activeDriverRoute!.occupancyStatus = null;
    }
    _activeDriverRoute = null;
    _activeDriverVariantId = null;
    _driverOccupancy = null;
    _activeTripStartedAt = null;
    _activeTripMaxStopIndex = 0;
    _activeTripPeakOccupancy = null;
    notifyListeners();
  }

  void updateOccupancy(OccupancyStatus status) {
    _driverOccupancy = status;

    if (_activeTripPeakOccupancy == null ||
        _occupancyScore(status) > _occupancyScore(_activeTripPeakOccupancy!)) {
      _activeTripPeakOccupancy = status;
    }

    if (_activeDriverRoute != null) {
      _activeDriverRoute!.occupancyStatus = status;
      _activeDriverRoute!.occupancyLastUpdated = DateTime.now();
    }
    notifyListeners();
  }

  int _occupancyScore(OccupancyStatus status) {
    switch (status) {
      case OccupancyStatus.seatAvailable:
        return 1;
      case OccupancyStatus.limitedSeats:
        return 2;
      case OccupancyStatus.fullCapacity:
        return 3;
    }
  }

  void addRecentRoute(BusRoute route, String variantId) {
    final variant = route.variantById(variantId) ?? route.defaultVariant;

    _recentRoutes.removeWhere(
      (e) => e.routeId == route.id && e.variantId == variant.id,
    );
    _recentRoutes.insert(
      0,
      RecentRouteEntry(
        routeId: route.id,
        routeCode: route.code,
        routeName: route.name,
        variantId: variant.id,
        variantLabel: variant.shortLabel,
        viewedAt: DateTime.now(),
      ),
    );

    if (_recentRoutes.length > 25) {
      _recentRoutes.removeRange(25, _recentRoutes.length);
    }

    _saveRecentRoutes();
  }

  Future<void> _saveRecentRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      _recentRoutes.map((e) => e.toJson()).toList(growable: false),
    );
    await prefs.setString(_recentRoutesKey, payload);
  }

  Future<void> _saveDriverTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      _driverTripHistory.map((e) => e.toJson()).toList(growable: false),
    );
    await prefs.setString(_driverTripsKey, payload);
  }

  void updateRouteStatus(String routeId, RouteStatus status) {
    final idx = _routes.indexWhere((r) => r.id == routeId);
    if (idx != -1) {
      _routes[idx].status = status;
      notifyListeners();
    }
  }

  Future<bool> requestLocationPermission() async {
    _isLoadingLocation = true;
    notifyListeners();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isLoadingLocation = false;
      notifyListeners();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isLoadingLocation = false;
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _isLoadingLocation = false;
      notifyListeners();
      return false;
    }

    _locationPermissionGranted = true;
    await _getCurrentLocation();
    return true;
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      // Keep default Davao City center
    }
    _isLoadingLocation = false;
    notifyListeners();
  }

  void setLocationPermissionGranted(bool value) {
    _locationPermissionGranted = value;
    notifyListeners();
  }

  // Start tracking live location (call when on active route screen)
  void startLiveTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });
  }
}
