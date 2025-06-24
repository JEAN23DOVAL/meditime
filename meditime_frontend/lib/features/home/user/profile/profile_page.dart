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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 32),
            ProfileQuickActions(
              onSettings: () {context.push(AppRoutes.settings);},
              onDocuments: () {context.push(AppRoutes.documents);},
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
              onFavorites: user?.role == 'patient' ? () {context.push(AppRoutes.favorites);} : null,
              onStats: user?.role == 'doctor' ? () {context.push(AppRoutes.stats);} : null,
              isDoctor: user?.role == 'doctor',
            ),
            const SizedBox(height: 32),

            // SECTION COMPTE
            const ProfileSectionTitle(title: 'Compte'),
            ProfileOptionTile(
              icon: Icons.person,
              title: 'Modifier le profil',
              subtitle: 'Changez vos informations',
              onTap: () {
                context.push(AppRoutes.editProfile); 
              },
            ),
            ProfileOptionTile(
              icon: Icons.lock,
              title: 'Sécurité',
              subtitle: 'Mot de passe, confidentialité',
              onTap: () {
                context.push(AppRoutes.security);
              },
            ),
            ProfileOptionTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Gérez vos notifications',
              onTap: () {
                context.push(AppRoutes.notifications);
              },
            ),
            if (user?.role == 'patient' || user?.role == 'doctor')
              ProfileOptionTile(
                icon: Icons.group,
                title: 'Ajouter un proche',
                subtitle: 'Gérez vos proches',
                onTap: () {
                  context.push(AppRoutes.addRelative);
                },
              ),

            // SECTION SANTÉ (PATIENT)
            if (user?.role == 'patient' || user?.role == 'doctor')
              ...[
                const ProfileSectionTitle(title: 'Santé'),
                ProfileOptionTile(
                  icon: Icons.health_and_safety,
                  title: 'Carnet de santé',
                  subtitle: 'Allergies, traitements, antécédents',
                  onTap: () {
                    context.push(AppRoutes.healthRecord);
                  },
                ),
              ],

            // SECTION MÉDECIN
            if (user?.role == 'doctor')
              ...[
                const ProfileSectionTitle(title: 'Médecin'),
                ProfileOptionTile(
                  icon: Icons.people,
                  title: 'Mes patients',
                  subtitle: 'Liste et historique',
                  onTap: () {
                    context.push(AppRoutes.patientsList);
                  },
                ),
                ProfileOptionTile(
                  icon: Icons.schedule,
                  title: 'Mes créneaux horaires',
                  subtitle: 'Gérez vos disponibilités',
                  onTap: () { context.go(AppRoutes.creneaudoctor); },
                ),
                ProfileOptionTile(
                  icon: Icons.edit_note,
                  title: 'Compléter mes informations',
                  subtitle: 'Ajoutez vos infos pro',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExtraInfoFormPage(doctorId: user!.doctorId!),
                      ),
                    );
                  },
                ),
                ProfileOptionTile(
                  icon: Icons.reviews,
                  title: 'Avis reçus',
                  subtitle: 'Voir et répondre aux avis',
                  onTap: () {
                    context.push(AppRoutes.reviews);
                  },
                ),
              ],

            // SECTION ASSISTANCE
            const ProfileSectionTitle(title: 'Assistance'),
            ProfileOptionTile(
              icon: Icons.help,
              title: 'Aide & Support',
              subtitle: 'FAQ, contact, assistance',
              onTap: () {
                context.push(AppRoutes.help);
              },
            ),
            ProfileOptionTile(
              icon: Icons.language,
              title: 'Langue',
              subtitle: 'Changer la langue',
              onTap: () {
                context.push(AppRoutes.language);
              },
            ),
          ],
        ),
      ),
    );
  }
}