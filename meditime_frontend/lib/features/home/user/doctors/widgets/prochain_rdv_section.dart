import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/prochain_rdv_card.dart';
import 'package:meditime_frontend/models/user_model.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';

class UpcomingRdvSection extends ConsumerWidget {
  const UpcomingRdvSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) return const SizedBox.shrink();

    final isDoctor = user.role == 'doctor';

    final nextPatientRdvAsync = ref.watch(nextPatientRdvProvider);
    final nextDoctorRdvAsync = isDoctor ? ref.watch(nextDoctorRdvProvider) : const AsyncValue.data(null);

    // Affiche la section seulement si au moins un rdv existe
    final hasAnyRdv = (nextPatientRdvAsync.value != null) || (nextDoctorRdvAsync.value != null);

    if (!hasAnyRdv) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          child: Text(
            'Prochain rendez-vous',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 160, // Augmente un peu la hauteur pour la carte
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              if (nextPatientRdvAsync.value != null)
                SizedBox(
                  width: 340, // Largeur fixe pour la carte
                  child: UpcomingRdvCard(
                    rdv: nextPatientRdvAsync.value!,
                    currentUser: user,
                    onMessage: () {
                      // Ouvre la conversation (à adapter selon ta logique)
                    },
                  ),
                ),
              if (isDoctor && nextDoctorRdvAsync.value != null)
                SizedBox(
                  width: 340,
                  child: UpcomingRdvCard(
                    rdv: nextDoctorRdvAsync.value!,
                    currentUser: user,
                    onMessage: () {
                      // Ouvre la conversation (à adapter selon ta logique)
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}