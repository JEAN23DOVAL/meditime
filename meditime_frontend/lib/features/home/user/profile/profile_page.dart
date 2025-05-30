import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_header.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_option_tile.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_quick_qctions.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/services/logout_service.dart';
import 'package:meditime_frontend/features/home/user/doctors/extra_info_form.dart';

class ProfilPage extends ConsumerWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textLight),
            onPressed: () {
              // Action modifier le profil
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 32),
            ProfileQuickActions(
              onSettings: () {},
              onHistory: () {},
              onLogout: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous quitter l\'application ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true) {
                  final router = GoRouter.of(context);
                  await handleLogout(ref, router);
                }
              },
            ),
            const SizedBox(height: 32),
            const ProfileSectionTitle(title: 'Options'),
            const SizedBox(height: 16),
            ProfileOptionTile(
              icon: Icons.person,
              title: 'Modifier le profil',
              subtitle: 'Changez vos informations',
              onTap: () {},
            ),
            // Option visible uniquement pour les docteurs
            if (user?.role == 'doctor')
              ProfileOptionTile(
                icon: Icons.schedule,
                title: 'Mes créneaux horaires',
                subtitle: 'Gérez vos disponibilités',
                onTap: () {
                  context.go(AppRoutes.creneaudoctor);
                },
              ),
            if (user?.role == 'doctor')
              ProfileOptionTile(
                icon: Icons.edit_note,
                subtitle: 'Ajoutez vos informations',
                // icon: Icons.edit_note,
                title: 'Compléter mes informations',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ExtraInfoFormPage(doctorId: user!.doctorId!), // ou idUser selon ton modèle
                    ),
                  );
                },
              ),
            ProfileOptionTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Gérez vos notifications',
              onTap: () {},
            ),
            ProfileOptionTile(
              icon: Icons.help,
              title: 'Aide',
              subtitle: 'Obtenez de l\'aide ou contactez-nous',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}