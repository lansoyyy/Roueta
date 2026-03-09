import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverAccount {
  final String username;
  final String password;
  final String name;
  final String badge; // bus/plate identifier

  const DriverAccount({
    required this.username,
    required this.password,
    required this.name,
    required this.badge,
  });
}

class AuthProvider extends ChangeNotifier {
  bool _isDriverLoggedIn = false;
  String? _driverUsername;
  String? _driverName;
  String? _driverBadge;
  bool _isLoading = false;
  bool _initialized = false;

  bool get isDriverLoggedIn => _isDriverLoggedIn;
  String? get driverUsername => _driverUsername;
  String? get driverName => _driverName;
  String? get driverBadge => _driverBadge;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;

  // Fixed local driver/konduktor accounts.
  // Authentication is intentionally local-only (store/get from device).
  static const List<DriverAccount> _accounts = [
    DriverAccount(
      username: 'driver01',
      password: 'roueta123',
      name: 'Juan Dela Cruz',
      badge: 'BUS-001',
    ),
    DriverAccount(
      username: 'driver02',
      password: 'roueta123',
      name: 'Pedro Santos',
      badge: 'BUS-002',
    ),
    DriverAccount(
      username: 'konduktor01',
      password: 'roueta123',
      name: 'Maria Garcia',
      badge: 'BUS-003',
    ),
    DriverAccount(
      username: 'konduktor02',
      password: 'roueta123',
      name: 'Ana Reyes',
      badge: 'BUS-004',
    ),
    DriverAccount(
      username: 'admin',
      password: 'admin123',
      name: 'Admin Driver',
      badge: 'BUS-ADM',
    ),
  ];

  /// Call once at app startup to restore persisted session
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDriverLoggedIn = prefs.getBool('driver_logged_in') ?? false;
    _driverUsername = prefs.getString('driver_username');
    _driverName = prefs.getString('driver_name');
    _driverBadge = prefs.getString('driver_badge');
    _initialized = true;
    notifyListeners();
  }

  /// Validates credentials against the demo account list.
  /// Returns [true] on success, [false] on failure.
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 900));

    DriverAccount? found;
    try {
      found = _accounts.firstWhere(
        (a) =>
            a.username == username.trim().toLowerCase() &&
            a.password == password,
      );
    } catch (_) {
      found = null;
    }

    if (found != null) {
      _isDriverLoggedIn = true;
      _driverUsername = found.username;
      _driverName = found.name;
      _driverBadge = found.badge;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('driver_logged_in', true);
      await prefs.setString('driver_username', found.username);
      await prefs.setString('driver_name', found.name);
      await prefs.setString('driver_badge', found.badge);

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Clears the driver session
  Future<void> logout() async {
    _isDriverLoggedIn = false;
    _driverUsername = null;
    _driverName = null;
    _driverBadge = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_logged_in');
    await prefs.remove('driver_username');
    await prefs.remove('driver_name');
    await prefs.remove('driver_badge');

    notifyListeners();
  }
}
