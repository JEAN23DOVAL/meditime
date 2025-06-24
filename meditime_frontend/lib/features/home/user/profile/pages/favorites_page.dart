import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';
import 'package:meditime_frontend/models/doctor_model.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simule des médecins favoris, à remplacer par le backend plus tard
    final favorites = [
      Doctor(
        id: 1,
        idUser: 11,
        specialite: 'Cardiologue',
        diplomes: 'DES Cardiologie',
        numeroInscription: '12345',
        hopital: 'Hôpital Central',
        adresseConsultation: 'Yaoundé',
        note: 4.8,
        createdAt: DateTime.now(),
      ),
      Doctor(
        id: 2,
        idUser: 12,
        specialite: 'Pédiatre',
        diplomes: 'DES Pédiatrie',
        numeroInscription: '67890',
        hopital: 'Hôpital Général',
        adresseConsultation: 'Douala',
        note: 4.6,
        createdAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Médecins favoris'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSectionTitle(title: 'Vos favoris'),
          const SizedBox(height: 16),
          ...favorites.map((doctor) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red, size: 32),
                  title: Text(
                    'Dr. ${doctor.idUser} - ${doctor.specialite}',
                    style: AppStyles.bodyText,
                  ),
                  subtitle: Text('${doctor.hopital} • ${doctor.adresseConsultation}', style: AppStyles.caption),
                  trailing: Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 18),
                  onTap: () {
                    // TODO: Naviguer vers la fiche du médecin
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fiche médecin à venir...')),
                    );
                  },
                ),
              )),
        ],
      ),
    );
  }
}