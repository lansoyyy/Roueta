import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: ClipOval(
                      child: CustomPaint(painter: _MiniLogoPainter()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'RouETA',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            const SizedBox(height: 8),

            // Mode toggle: Passenger / Driver
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryVeryLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeTab(
                        label: 'Passenger',
                        icon: Icons.directions_bus,
                        isActive: provider.userMode == UserMode.passenger,
                        onTap: () {
                          provider.setUserMode(UserMode.passenger);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: _ModeTab(
                        label: 'Driver',
                        icon: Icons.drive_eta,
                        isActive: provider.userMode == UserMode.driver,
                        onTap: () {
                          provider.setUserMode(UserMode.driver);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Menu items
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Your Profile',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Profile');
              },
            ),
            _DrawerItem(
              icon: Icons.notifications_none,
              label: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Notifications');
              },
            ),
            _DrawerItem(
              icon: Icons.help_outline,
              label: 'Help and Feedback',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Help and Feedback');
              },
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Settings');
              },
            ),

            const Spacer(),

            // App version
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Davao Interim Bus Service\nv1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature – Coming Soon'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppColors.primaryDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 26),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}

class _MiniLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF006064)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.addRect(Rect.fromLTWH(w * 0.2, h * 0.4, w * 0.6, h * 0.5));
    path.moveTo(w * 0.1, h * 0.4);
    path.lineTo(w * 0.5, h * 0.1);
    path.lineTo(w * 0.9, h * 0.4);
    path.close();
    canvas.drawPath(path, paint);

    final door = Path();
    door.addRect(Rect.fromLTWH(w * 0.38, h * 0.6, w * 0.24, h * 0.3));
    canvas.drawPath(door, Paint()..color = AppColors.primaryLight);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'ROU\nETA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: w);
    textPainter.paint(canvas, Offset((w - textPainter.width) / 2, h * 0.48));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
