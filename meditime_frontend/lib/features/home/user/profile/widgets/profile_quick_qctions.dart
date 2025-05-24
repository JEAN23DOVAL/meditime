import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';

class ProfileQuickActions extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onHistory;
  final VoidCallback onLogout;

  const ProfileQuickActions({
    super.key,
    required this.onSettings,
    required this.onHistory,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickAction(icon: Icons.settings, label: 'Paramètres', onTap: onSettings),
        _buildQuickAction(icon: Icons.history, label: 'Historique', onTap: onHistory),
        _buildQuickAction(icon: Icons.logout, label: 'Déconnexion', onTap: onLogout),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.textLight, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppStyles.bodyText.copyWith(color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}