import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool rdvReminder = true;
  bool messageNotif = true;
  bool newsNotif = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSectionTitle(title: 'Préférences'),
          SwitchListTile(
            secondary: const Icon(Icons.calendar_today, color: AppColors.primary),
            title: const Text('Rappels de rendez-vous', style: AppStyles.bodyText),
            value: rdvReminder,
            onChanged: (v) => setState(() => rdvReminder = v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.message, color: AppColors.primary),
            title: const Text('Nouvelles discussions/messages', style: AppStyles.bodyText),
            value: messageNotif,
            onChanged: (v) => setState(() => messageNotif = v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.campaign, color: AppColors.primary),
            title: const Text('Actualités et conseils santé', style: AppStyles.bodyText),
            value: newsNotif,
            onChanged: (v) => setState(() => newsNotif = v),
          ),
        ],
      ),
    );
  }
}