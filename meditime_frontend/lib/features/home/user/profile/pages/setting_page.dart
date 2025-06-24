import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSectionTitle(title: 'Général'),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: AppColors.primary),
            title: const Text('Mode sombre', style: AppStyles.bodyText),
            trailing: Switch(
              value: false,
              onChanged: (v) {
                // TODO: Gérer le changement de thème
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir...')),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: AppColors.primary),
            title: const Text('Notifications', style: AppStyles.bodyText),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              // TODO: Naviguer vers la page notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications à venir...')),
              );
            },
          ),
        ],
      ),
    );
  }
}