import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';
import 'package:meditime_frontend/models/user_model.dart';

class PatientsListPage extends StatelessWidget {
  const PatientsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simule des patients, à remplacer par le backend plus tard
    final patients = [
      User(
        idUser: 1,
        lastName: 'Nguefack',
        firstName: 'Paul',
        email: 'paul.nguefack@email.com',
        role: 'patient',
        isVerified: true,
      ),
      User(
        idUser: 2,
        lastName: 'Mbianda',
        firstName: 'Alice',
        email: 'alice.mbianda@email.com',
        role: 'patient',
        isVerified: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes patients'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSectionTitle(title: 'Liste des patients'),
          const SizedBox(height: 16),
          ...patients.map((patient) => ListTile(
                leading: const Icon(Icons.person, color: AppColors.primary),
                title: Text(
                  '${patient.lastName} ${patient.firstName ?? ''}',
                  style: AppStyles.bodyText,
                ),
                subtitle: Text(patient.email, style: AppStyles.caption),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  // TODO: Naviguer vers la fiche patient ou historique RDV
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fiche patient à venir...')),
                  );
                },
              )),
        ],
      ),
    );
  }
}