import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/app_drawer.dart';
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
  int _selectedIndex = 1; // 0 = bus, 1 = map/location, 2 = profile
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().startLiveTracking();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBody(AppProvider provider) {
    if (_selectedIndex == 0) {
      // Routes screen (passenger or driver)
      return provider.userMode == UserMode.driver
          ? const DriverRoutesScreen()
          : const PassengerRoutesScreen();
    }

    if (_selectedIndex == 2) {
      return const ProfileScreen();
    }

    // Map view (index 1)
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: provider.currentLatLng,
        zoom: 13.5,
      ),
      onMapCreated: (ctrl) => _mapController = ctrl,
      myLocationEnabled: provider.locationPermissionGranted,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      buildingsEnabled: true,
      compassEnabled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top App Bar
          _TopBar(
            scaffoldKey: _scaffoldKey,
            searchController: _searchController,
            onSearch: (q) => provider.setSearchQuery(q),
          ),

          // Body
          Expanded(child: _buildBody(provider)),
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

// ──────────────────────────── Top Bar ────────────────────────────
class _TopBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  const _TopBar({
    required this.scaffoldKey,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
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
          // Hamburger
          GestureDetector(
            onTap: () => scaffoldKey.currentState?.openDrawer(),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.menu, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 10),

          // Search bar
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
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'SEARCH',
                        hintStyle: TextStyle(
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
        ],
      ),
    );
  }
}

// ──────────────────────────── Bottom Nav ────────────────────────────
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
          height: 62,
          child: Stack(
            children: [
              // Nav items
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
              // Center ROUTES FAB
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
                      const Text(
                        'ROUTES',
                        style: TextStyle(
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
            size: 28,
          ),
        ),
      ),
    );
  }
}

