import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';

class ProfileQuickActions extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onDocuments;
  final VoidCallback onLogout;
  final VoidCallback? onFavorites;
  final VoidCallback? onStats;
  final bool isDoctor;

  const ProfileQuickActions({
    super.key,
    required this.onSettings,
    required this.onDocuments,
    required this.onLogout,
    this.onFavorites,
    this.onStats,
    this.isDoctor = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickAction(icon: Icons.settings, label: 'Paramètres', onTap: onSettings),
          _buildQuickAction(icon: Icons.folder, label: 'Documents', onTap: onDocuments),
          if (!isDoctor && onFavorites != null)
            _buildQuickAction(icon: Icons.favorite, label: 'Favoris', onTap: onFavorites!),
          if (isDoctor && onStats != null)
            _buildQuickAction(icon: Icons.bar_chart, label: 'Statistiques', onTap: onStats!),
          _buildQuickAction(icon: Icons.logout, label: 'Déconnexion', onTap: onLogout),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80, // Fixe la largeur pour éviter l’overflow
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
              child: Icon(icon, color: AppColors.textLight, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppStyles.bodyText.copyWith(
                color: AppColors.textDark,
                fontSize: 11, // Texte plus petit
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}