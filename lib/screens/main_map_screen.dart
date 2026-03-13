import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_drawer.dart';
import 'auth/driver_login_screen.dart';
import 'passenger/passenger_routes_screen.dart';
import 'driver/driver_routes_screen.dart';
import 'profile_screen.dart';

class MainMapScreen extends StatefulWidget {
  const MainMapScreen({super.key});

  @override
  State<MainMapScreen> createState() => _MainMapScreenState();
}

class _MainMapScreenState extends State<MainMapScreen> {
  GoogleMapController? _mapController;
  /// 0 = routes/bus tab, 1 = live map, 2 = profile
  int _selectedIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      context.read<AppProvider>().startLiveTracking(
        accuracy: settings.locationAccuracy,
      );
      if (settings.autoCenter) _centerOnUser();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _centerOnUser() {
    final provider = context.read<AppProvider>();
    if (provider.locationPermissionGranted && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(provider.currentLatLng),
      );
    }
  }

  // ── Build body based on selected tab ─────────────────────────────────────

  Widget _buildBody(AppProvider provider, SettingsProvider settings) {
    if (_selectedIndex == 0) {
      if (provider.userMode == UserMode.driver) {
        final auth = context.read<AuthProvider>();
        if (!auth.isDriverLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.setUserMode(UserMode.passenger);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriverLoginScreen()),
            );
          });
          return const PassengerRoutesScreen();
        }
        return const DriverRoutesScreen();
      }
      return const PassengerRoutesScreen();
    }

    if (_selectedIndex == 2) return const ProfileScreen();

    // ── Live map view (index 1) ──────────────────────────────────────────
    return _LiveMapView(
      mapController: _mapController,
      onMapCreated: (ctrl) {
        _mapController = ctrl;
        if (settings.autoCenter) _centerOnUser();
      },
      provider: provider,
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _TopBar(
            scaffoldKey: _scaffoldKey,
            searchController: _searchController,
            onSearch: (q) => provider.setSearchQuery(q),
            unreadCount: provider.unreadNotificationCount,
          ),
          Expanded(child: _buildBody(provider, settings)),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        userMode: provider.userMode,
      ),
    );
  }
}

// ── Live map with active bus markers ─────────────────────────────────────────

class _LiveMapView extends StatelessWidget {
  final GoogleMapController? mapController;
  final MapCreatedCallback onMapCreated;
  final AppProvider provider;
  final SettingsProvider settings;

  const _LiveMapView({
    required this.mapController,
    required this.onMapCreated,
    required this.provider,
    required this.settings,
  });

  Set<Marker> _buildBusMarkers() {
    return provider.activeBusLocations.values.map((bus) {
      return Marker(
        markerId: MarkerId('bus_${bus.driverBadge}'),
        position: bus.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: '${bus.driverBadge} — ${bus.routeId.toUpperCase()}',
          snippet: bus.driverName,
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final buses = _buildBusMarkers();

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: provider.currentLatLng,
            zoom: 13.5,
          ),
          onMapCreated: onMapCreated,
          mapType: settings.googleMapType,
          trafficEnabled: settings.showTraffic,
          myLocationEnabled: provider.locationPermissionGranted,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          buildingsEnabled: true,
          compassEnabled: false,
          markers: buses,
        ),
        // Active bus count badge
        if (buses.isNotEmpty)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_bus,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${buses.length} active',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // My location button
        if (provider.locationPermissionGranted)
          Positioned(
            bottom: 20,
            right: 12,
            child: GestureDetector(
              onTap: () {
                mapController?.animateCamera(
                  CameraUpdate.newLatLng(provider.currentLatLng),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final int unreadCount;

  const _TopBar({
    required this.scaffoldKey,
    required this.searchController,
    required this.onSearch,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Container(
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
            onTap: () => scaffoldKey.currentState?.openDrawer(),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.menu, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearch,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: settings.tr('search_hint'),
                        hintStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final UserMode userMode;

  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.userMode,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Stack(
            children: [
              Row(
                children: [
                  _NavItem(
                    icon: Icons.directions_bus,
                    isSelected: selectedIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  const Spacer(),
                  _NavItem(
                    icon: Icons.person_outline,
                    isSelected: selectedIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ],
              ),
              Center(
                child: GestureDetector(
                  onTap: () => onTap(1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      Text(
                        settings.tr('routes'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        height: 62,
        child: Center(
          child: Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.grey[400],
            size: 26,
          ),
        ),
      ),
    );
  }
}
