import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isDriverLoggedIn = false;
  String? _driverUsername;
  String? _driverName;
  String? _driverBadge;
  List<String> _assignedRoutes = [];
  bool _isLoading = false;
  bool _initialized = false;

  bool get isDriverLoggedIn => _isDriverLoggedIn;
  String? get driverUsername => _driverUsername;
  String? get driverName => _driverName;
  String? get driverBadge => _driverBadge;
  List<String> get assignedRoutes => List.unmodifiable(_assignedRoutes);
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;

  // ── Local fallback accounts ───────────────────────────────────────────────
  static const List<Map<String, dynamic>> _fallbackAccounts = [
    {
      'username': 'driver01',
      'password': 'roueta123',
      'name': 'Juan Dela Cruz',
      'badge': 'BUS-001',
      'assignedRoutes': ['r102', 'r103'],
    },
    {
      'username': 'driver02',
      'password': 'roueta123',
      'name': 'Pedro Santos',
      'badge': 'BUS-002',
      'assignedRoutes': ['r402', 'r403'],
    },
    {
      'username': 'konduktor01',
      'password': 'roueta123',
      'name': 'Maria Garcia',
      'badge': 'BUS-003',
      'assignedRoutes': ['r503', 'r603'],
    },
    {
      'username': 'konduktor02',
      'password': 'roueta123',
      'name': 'Ana Reyes',
      'badge': 'BUS-004',
      'assignedRoutes': ['r763', 'r783'],
    },
    {
      'username': 'admin',
      'password': 'admin123',
      'name': 'Admin Driver',
      'badge': 'BUS-ADM',
      'assignedRoutes': ['r102', 'r103', 'r402', 'r403', 'r503', 'r603', 'r763', 'r783', 'r793'],
    },
  ];

  /// Restore persisted session and seed Firestore accounts if needed.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDriverLoggedIn = prefs.getBool('driver_logged_in') ?? false;
    _driverUsername = prefs.getString('driver_username');
    _driverName = prefs.getString('driver_name');
    _driverBadge = prefs.getString('driver_badge');
    final encodedRoutes = prefs.getStringList('driver_assigned_routes');
    _assignedRoutes = encodedRoutes ?? [];
    _initialized = true;
    notifyListeners();

    // Seed Firestore driver accounts asynchronously.
    FirestoreService().seedDriverAccounts();
  }

  /// Authenticate against Firestore first, then fall back to local list.
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate minimum UI feedback delay.
    await Future.delayed(const Duration(milliseconds: 600));

    Map<String, dynamic>? found;

    // 1. Try Firestore
    try {
      final data = await FirestoreService().getDriverAccount(
        username.trim().toLowerCase(),
      );
      if (data != null && data['password'] == password) {
        found = data;
      }
    } catch (_) {}

    // 2. Fallback to local list
    if (found == null) {
      final local = _fallbackAccounts.firstWhere(
        (a) =>
            a['username'] == username.trim().toLowerCase() &&
            a['password'] == password,
        orElse: () => <String, dynamic>{},
      );
      if (local.isNotEmpty) found = local;
    }

    if (found != null) {
      _isDriverLoggedIn = true;
      _driverUsername = found['username'] as String?;
      _driverName = found['name'] as String?;
      _driverBadge = found['badge'] as String?;
      final routes = found['assignedRoutes'];
      _assignedRoutes = routes is List
          ? routes.cast<String>()
          : <String>[];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('driver_logged_in', true);
      await prefs.setString('driver_username', _driverUsername ?? '');
      await prefs.setString('driver_name', _driverName ?? '');
      await prefs.setString('driver_badge', _driverBadge ?? '');
      await prefs.setStringList('driver_assigned_routes', _assignedRoutes);

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isDriverLoggedIn = false;
    _driverUsername = null;
    _driverName = null;
    _driverBadge = null;
    _assignedRoutes = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_logged_in');
    await prefs.remove('driver_username');
    await prefs.remove('driver_name');
    await prefs.remove('driver_badge');
    await prefs.remove('driver_assigned_routes');

    notifyListeners();
  }
}
