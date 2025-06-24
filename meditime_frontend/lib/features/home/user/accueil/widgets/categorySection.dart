import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/become_doctor.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/bestSection.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/completer_compte.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/doctor_nearby_section.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/prochain_rdv_section.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart'; // <-- utilise ton vrai provider

class CategorySection extends ConsumerWidget {
  CategorySection({super.key});

  // Création de la liste pour les différentes catégories avec des icônes de Material Design
  final category = [
  {
    'icon': MdiIcons.heartPulse,
    'color': Color(0xFFFFEBEE), // Rouge très clair
    'iconColor': Colors.red,
    'title': 'Cardiologie',
  },
  {
    'icon': MdiIcons.brain,
    'color': Color(0xFFFCE4EC), // Rose très clair
    'iconColor': Colors.pink,
    'title': 'Neurologie',
  },

  {
    'icon': MdiIcons.stethoscope,
    'color': Color(0xFFE3F2FD), // Bleu très clair
    'iconColor': Colors.blue,
    'title': 'Médecine générale',
  },

  {
    'icon': MdiIcons.bacteria,
    'color': Color(0xFFE8F5E9), // Vert très clair
    'iconColor': Colors.green,
    'title': 'Infectiologie',
  },

  {
    'icon': MdiIcons.reproduction,
    'color': Color(0xFFFFF3E0), // Orange très clair
    'iconColor': Colors.orange,
    'title': 'Pédiatrie',
  },

  {
    'icon': MdiIcons.tooth,
    'color': Color(0xFFE0F2F1), // Teal clair
    'iconColor': Colors.teal,
    'title': 'Dentiste',
  },

  {
    'icon': MdiIcons.genderFemale,
    'color': Color(0xFFF3E5F5), // Violet clair
    'iconColor': Colors.purple,
    'title': 'Gynécologie',
  },

  {
    'icon': MdiIcons.eye,
    'color': Color(0xFFE8EAF6), // Indigo clair
    'iconColor': Colors.indigo,
    'title': 'Ophtalmologie',
  },

  {
    'icon': MdiIcons.humanMaleBoard,
    'color': Color(0xFFD7CCC8), // Marron clair (beige)
    'iconColor': Colors.brown,
    'title': 'Orthopédie',
  },

  {
    'icon': MdiIcons.head,
    'color': Color(0xFFEDE7F6), // Violet profond très clair
    'iconColor': Colors.deepPurple,
    'title': 'Psychiatrie',
  },

  {
    'icon': MdiIcons.radiologyBox,
    'color': Color(0xFFEEEEEE), // Gris doux
    'iconColor': Colors.grey,
    'title': 'Radiologie',
  },

  {
    'icon': MdiIcons.doctor,
    'color': Color(0xFFE1F5FE), // Bleu très clair
    'iconColor': Colors.blueAccent,
    'title': 'Chirurgie',
  },

  {
    'icon': MdiIcons.medicalBag,
    'color': Color(0xFFFFEBEE), // Rouge orangé clair
    'iconColor': Colors.deepOrange,
    'title': 'Anesthésie',
  },

  {
    'icon': MdiIcons.earHearing,
    'color': Color(0xFFE0F7FA), // Cyan clair
    'iconColor': Colors.cyan,
    'title': 'Otites',
  },

  {
    'icon': MdiIcons.flask,
    'color': Color(0xFFFFF8E1), // Jaune très pâle
    'iconColor': Colors.amber,
    'title': 'Endocrinologie',
  },

  {
    'icon': MdiIcons.lungs,
    'color': Color(0xFFE1F5FE), // Bleu ciel clair
    'iconColor': Colors.lightBlue,
    'title': 'Maladies pulmonaires',
  },

  {
    'icon': MdiIcons.hospitalBoxOutline,
    'color': Color(0xFFF5F5F5), // Neutre doux
    'iconColor': Colors.black,
    'title': 'Voir tout',
  },

];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8FF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 25),
                scrollDirection: Axis.horizontal,
                itemBuilder: ((context, index) => Column(
                  children: [
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: category[index]['color'] as Color,
                      ),
                      child: Icon(
                        category[index]['icon'] as IconData,
                        color: category[index]['iconColor'] as Color,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category[index]['title'] as String,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )),
                separatorBuilder: ((context, index) => SizedBox(width: 20)),
                itemCount: category.length,
              ),
            ),

            // Afficher la Confirmation de Compte si user existe et n'est pas confirmé
            if (user != null && user.isVerified == false) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ConfirmationAccount(),
              ),
            ],

            // ✅ Afficher le bouton uniquement si le rôle est "patient"
            if (user != null && user.role == 'patient') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: BecomeDoctor(),
              ),
            ],

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Meilleurs Docteurs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            BestSection(),
            const UpcomingRdvSection(),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Médecins proches de vous',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DoctorNearbySection(),
          ],
        ),
      ),
    );
  }
}