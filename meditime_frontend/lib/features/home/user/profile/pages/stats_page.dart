import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simule des stats, à remplacer par le backend plus tard
    final stats = {
      'consultations': 120,
      'patients': 80,
      'revenus': 1500000,
      'avis': 45,
      'note': 4.7,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSectionTitle(title: 'Vue d\'ensemble'),
          const SizedBox(height: 16),
          _buildStatTile(Icons.calendar_today, 'Consultations', stats['consultations'].toString()),
          _buildStatTile(Icons.people, 'Patients suivis', stats['patients'].toString()),
          _buildStatTile(Icons.attach_money, 'Revenus (FCFA)', stats['revenus'].toString()),
          _buildStatTile(Icons.reviews, 'Avis reçus', stats['avis'].toString()),
          _buildStatTile(Icons.star, 'Note moyenne', stats['note'].toString()),
        ],
      ),
    );
  }

  Widget _buildStatTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 32),
        title: Text(label, style: AppStyles.heading3),
        trailing: Text(value, style: AppStyles.heading2.copyWith(color: AppColors.secondary)),
      ),
    );
  }
}