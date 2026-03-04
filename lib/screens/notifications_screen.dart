import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Demo notification data
  final List<_NotifItem> _notifications = [
    _NotifItem(
      type: _NotifType.busApproaching,
      title: 'Your bus is 2 mins away!',
      body: 'R103 bus is 2 mins away from Ecoland Terminal bus stop.',
      time: DateTime.now().subtract(const Duration(minutes: 4)),
      isRead: false,
    ),
    _NotifItem(
      type: _NotifType.occupancyUpdate,
      title: 'Occupancy Update – R103',
      body:
          'Toril – GE Torres route is now reporting Limited Seats (~67% full).',
      time: DateTime.now().subtract(const Duration(minutes: 22)),
      isRead: false,
    ),
    _NotifItem(
      type: _NotifType.busApproaching,
      title: 'Your bus is 2 mins away!',
      body: 'R103 bus is 2 mins away from Matina Town Square bus stop.',
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      isRead: true,
    ),
    _NotifItem(
      type: _NotifType.routeStatus,
      title: 'Route Status Changed',
      body:
          'Mintal – GE Torres route is now operating. Buses are on the road.',
      time: DateTime.now().subtract(const Duration(hours: 3, minutes: 40)),
      isRead: true,
    ),
    _NotifItem(
      type: _NotifType.occupancyUpdate,
      title: 'Standing Only Alert – R104',
      body:
          'Talomo – Roxas route is at full capacity (~95%). Expect standing passengers.',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    _NotifItem(
      type: _NotifType.routeStatus,
      title: 'Route On Standby',
      body:
          'Bangkal – Roxas route has been placed on standby. Service will resume shortly.',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
    ),
    _NotifItem(
      type: _NotifType.busApproaching,
      title: 'Your bus is 2 mins away!',
      body: 'R104 bus is 2 mins away from Talomo Market bus stop.',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markRead(int index) {
    setState(() => _notifications[index].isRead = true);
  }

  void _deleteNotification(int index) {
    setState(() => _notifications.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (_, i) {
                final notif = _notifications[i];
                return Dismissible(
                  key: Key('notif_$i${notif.title}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.statusUnavailable,
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => _deleteNotification(i),
                  child: _NotificationTile(
                    item: notif,
                    onTap: () => _markRead(i),
                  ),
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _NotifItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  Color get _iconBg {
    switch (item.type) {
      case _NotifType.busApproaching:
        return AppColors.primary;
      case _NotifType.occupancyUpdate:
        return AppColors.accent;
      case _NotifType.routeStatus:
        return AppColors.statusOperating;
    }
  }

  IconData get _icon {
    switch (item.type) {
      case _NotifType.busApproaching:
        return Icons.directions_bus_rounded;
      case _NotifType.occupancyUpdate:
        return Icons.people_rounded;
      case _NotifType.routeStatus:
        return Icons.route_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isRead ? Colors.white : AppColors.primaryVeryLight,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(item.time),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bus alerts and updates will appear here.',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

enum _NotifType { busApproaching, occupancyUpdate, routeStatus }

class _NotifItem {
  final _NotifType type;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;

  _NotifItem({
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}
