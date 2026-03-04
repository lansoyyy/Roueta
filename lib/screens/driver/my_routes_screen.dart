import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/bus_route.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../active_bus_screen.dart';

class MyRoutesScreen extends StatefulWidget {
  const MyRoutesScreen({super.key});

  @override
  State<MyRoutesScreen> createState() => _MyRoutesScreenState();
}

class _MyRoutesScreenState extends State<MyRoutesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Routes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Assigned Routes'),
            Tab(text: 'Trip History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AssignedRoutesTab(),
          _TripHistoryTab(),
        ],
      ),
    );
  }
}

// ── Assigned Routes Tab ──────────────────────────────────────────────────────
class _AssignedRoutesTab extends StatelessWidget {
  const _AssignedRoutesTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final auth = context.watch<AuthProvider>();
    final routes = provider.routes;

    return Column(
      children: [
        // Driver info strip
        Container(
          width: double.infinity,
          color: AppColors.primaryVeryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.drive_eta_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.driverName ?? 'Driver',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Badge: ${auth.driverBadge ?? '—'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.statusOperating,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'On Duty',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Routes list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: routes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final route = routes[i];
              final isActive = provider.activeDriverRoute?.id == route.id;
              return _AssignedRouteCard(
                route: route,
                isActive: isActive,
                onTap: () {
                  if (route.status == RouteStatus.unavailable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('This route is currently unavailable'),
                        backgroundColor: AppColors.statusUnavailable,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  provider.setActiveDriverRoute(route);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActiveBusScreen(route: route),
                    ),
                  ).then((_) => provider.stopDriverRoute());
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AssignedRouteCard extends StatelessWidget {
  final BusRoute route;
  final bool isActive;
  final VoidCallback onTap;

  const _AssignedRouteCard({
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  Color get _statusColor {
    switch (route.status) {
      case RouteStatus.operating:
        return AppColors.statusOperating;
      case RouteStatus.onStandby:
        return AppColors.statusStandby;
      case RouteStatus.unavailable:
        return AppColors.statusUnavailable;
    }
  }

  String get _statusLabel {
    switch (route.status) {
      case RouteStatus.operating:
        return 'Operating';
      case RouteStatus.onStandby:
        return 'On Standby';
      case RouteStatus.unavailable:
        return 'Unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.primaryVeryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.navigation_rounded,
                      color: isActive ? Colors.white : AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
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
                                route.code,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${route.stops.length} stops',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Schedule row
              Row(
                children: [
                  _ScheduleChip(
                    label: 'AM',
                    time: '${route.amStartTime} – ${route.amEndTime}',
                  ),
                  const SizedBox(width: 8),
                  _ScheduleChip(
                    label: 'PM',
                    time: '${route.pmStartTime} – ${route.pmEndTime}',
                  ),
                ],
              ),

              // Start/Continue button
              if (!isActive) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: route.status == RouteStatus.unavailable
                        ? null
                        : onTap,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text(
                      'Start Route',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleChip extends StatelessWidget {
  final String label;
  final String time;
  const _ScheduleChip({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '$label  $time',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// ── Trip History Tab ──────────────────────────────────────────────────────────
class _TripHistoryTab extends StatelessWidget {
  const _TripHistoryTab();

  // Demo trip history data
  static final List<_TripRecord> _trips = [
    _TripRecord(
      routeName: 'Toril – GE Torres Route',
      routeCode: 'R103',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      startTime: '6:12 AM',
      endTime: '7:45 AM',
      stopsCompleted: 10,
      totalStops: 10,
      peakOccupancy: 'Full Capacity',
      occupancyColor: AppColors.statusUnavailable,
    ),
    _TripRecord(
      routeName: 'Toril – Roxas Route',
      routeCode: 'R103',
      date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      startTime: '1:05 PM',
      endTime: '2:33 PM',
      stopsCompleted: 10,
      totalStops: 10,
      peakOccupancy: 'Limited Seats',
      occupancyColor: AppColors.accent,
    ),
    _TripRecord(
      routeName: 'Mintal – GE Torres Route',
      routeCode: 'R103',
      date: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      startTime: '7:00 AM',
      endTime: '8:20 AM',
      stopsCompleted: 9,
      totalStops: 10,
      peakOccupancy: 'Seats Available',
      occupancyColor: AppColors.statusOperating,
    ),
    _TripRecord(
      routeName: 'Toril – GE Torres Route',
      routeCode: 'R103',
      date: DateTime.now().subtract(const Duration(days: 3)),
      startTime: '5:45 AM',
      endTime: '7:10 AM',
      stopsCompleted: 10,
      totalStops: 10,
      peakOccupancy: 'Full Capacity',
      occupancyColor: AppColors.statusUnavailable,
    ),
    _TripRecord(
      routeName: 'Bangkal – Roxas Route',
      routeCode: 'R103',
      date: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
      startTime: '2:00 PM',
      endTime: '3:15 PM',
      stopsCompleted: 10,
      totalStops: 10,
      peakOccupancy: 'Limited Seats',
      occupancyColor: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No trips yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed trips will appear here.',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Stats strip
        Container(
          color: AppColors.primaryVeryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _StatChip(
                label: 'Total Trips',
                value: '${_trips.length}',
                icon: Icons.route_rounded,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'This Week',
                value: '${_trips.where((t) => DateTime.now().difference(t.date).inDays < 7).length}',
                icon: Icons.calendar_today_rounded,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'Stops Done',
                value: '${_trips.fold<int>(0, (sum, t) => sum + t.stopsCompleted)}',
                icon: Icons.location_on_rounded,
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: _trips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _TripCard(trip: _trips[i]),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final _TripRecord trip;
  const _TripCard({required this.trip});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 24) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryVeryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.routeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
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
                              trip.routeCode,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(trip.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${trip.startTime} – ${trip.endTime}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Stats row
            Row(
              children: [
                _TripStat(
                  icon: Icons.location_on_rounded,
                  label: 'Stops',
                  value: '${trip.stopsCompleted}/${trip.totalStops}',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                _TripStat(
                  icon: Icons.people_rounded,
                  label: 'Peak Occupancy',
                  value: trip.peakOccupancy,
                  color: trip.occupancyColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TripStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TripRecord {
  final String routeName;
  final String routeCode;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int stopsCompleted;
  final int totalStops;
  final String peakOccupancy;
  final Color occupancyColor;

  const _TripRecord({
    required this.routeName,
    required this.routeCode,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.stopsCompleted,
    required this.totalStops,
    required this.peakOccupancy,
    required this.occupancyColor,
  });
}
