import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
               gradient: AppTheme.mainGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
