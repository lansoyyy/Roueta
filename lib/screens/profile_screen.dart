import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF26C6DA),
            Color(0xFF00ACC1),
            Color(0xFF00838F),
          ],
        ),
      ),
      child: Column(
        children: [
          const Expanded(
            child: _ProfileBody(),
          ),
        ],
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Avatar circle
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 70,
            ),
          ),
          const SizedBox(height: 24),

          // Greeting
          const Text(
            'Maayong Adlaw',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          // Username
          const Text(
            'username',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 48),

          // Recent Routes
          _ProfileMenuItem(
            icon: Icons.directions_bus_outlined,
            label: 'Recent Routes',
            onTap: () => _showComingSoon(context, 'Recent Routes'),
          ),
          const SizedBox(height: 16),

          // Feedback
          _ProfileMenuItem(
            icon: Icons.check_box_outlined,
            label: 'Feedback',
            onTap: () => _showComingSoon(context, 'Feedback'),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature – Coming Soon'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
