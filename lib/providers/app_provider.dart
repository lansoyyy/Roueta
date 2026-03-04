import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/bus_route.dart';
import '../data/routes_data.dart';

enum UserMode { passenger, driver }

class AppProvider extends ChangeNotifier {
  final List<BusRoute> _routes = RoutesData.routes;
  BusRoute? _selectedRoute;
  UserMode _userMode = UserMode.passenger;
  Position? _currentPosition;
  bool _locationPermissionGranted = false;
  bool _isLoadingLocation = false;
  String _searchQuery = '';
  BusRoute? _activeDriverRoute;
  OccupancyStatus? _driverOccupancy;

  // Getters
  List<BusRoute> get routes => _routes;
  BusRoute? get selectedRoute => _selectedRoute;
  UserMode get userMode => _userMode;
  Position? get currentPosition => _currentPosition;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get isLoadingLocation => _isLoadingLocation;
  String get searchQuery => _searchQuery;
  BusRoute? get activeDriverRoute => _activeDriverRoute;
  OccupancyStatus? get driverOccupancy => _driverOccupancy;

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
              r.destination.toLowerCase().contains(query),
        )
        .toList();
  }

  void setUserMode(UserMode mode) {
    _userMode = mode;
    notifyListeners();
  }

  void selectRoute(BusRoute route) {
    _selectedRoute = route;
    notifyListeners();
  }

  void clearSelectedRoute() {
    _selectedRoute = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveDriverRoute(BusRoute? route) {
    _activeDriverRoute = route;
    if (route != null) {
      route.status = RouteStatus.operating;
    }
    notifyListeners();
  }

  void stopDriverRoute() {
    if (_activeDriverRoute != null) {
      _activeDriverRoute!.status = RouteStatus.onStandby;
      _activeDriverRoute!.occupancyStatus = null;
    }
    _activeDriverRoute = null;
    _driverOccupancy = null;
    notifyListeners();
  }

  void updateOccupancy(OccupancyStatus status) {
    _driverOccupancy = status;
    if (_activeDriverRoute != null) {
      _activeDriverRoute!.occupancyStatus = status;
      _activeDriverRoute!.occupancyLastUpdated = DateTime.now();
    }
    notifyListeners();
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
