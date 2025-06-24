import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';

class HealthRecordPage extends StatelessWidget {
  const HealthRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simule des données, à remplacer par le backend plus tard
    final allergies = ['Pénicilline', 'Arachides'];
    final chronicDiseases = ['Diabète type 2'];
    final treatments = ['Metformine 500mg', 'Ventoline'];
    final bloodType = 'O+';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carnet de santé'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSectionTitle(title: 'Informations médicales'),
          const SizedBox(height: 16),
          _buildInfoTile(
            icon: Icons.bloodtype,
            label: 'Groupe sanguin',
            value: bloodType,
          ),
          const SizedBox(height: 16),
          _buildListTile(
            icon: Icons.warning_amber_rounded,
            label: 'Allergies',
            items: allergies,
          ),
          const SizedBox(height: 16),
          _buildListTile(
            icon: Icons.healing,
            label: 'Maladies chroniques',
            items: chronicDiseases,
          ),
          const SizedBox(height: 16),
          _buildListTile(
            icon: Icons.medication,
            label: 'Traitements en cours',
            items: treatments,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Modifier', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                // TODO: Naviguer vers la page d’édition du carnet de santé
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 32),
      title: Text(label, style: AppStyles.heading3.copyWith(color: AppColors.textDark)),
      subtitle: Text(value, style: AppStyles.bodyText),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildListTile({required IconData icon, required String label, required List<String> items}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 32),
      title: Text(label, style: AppStyles.heading3.copyWith(color: AppColors.textDark)),
      subtitle: items.isEmpty
          ? Text('Aucune information', style: AppStyles.bodyText.copyWith(color: Colors.grey))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((e) => Text('• $e', style: AppStyles.bodyText)).toList(),
            ),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}