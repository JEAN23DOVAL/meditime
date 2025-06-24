import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/providers/doctor_nearby_provider.dart';
import 'doctor_nearby_card.dart';

class DoctorNearbySection extends ConsumerWidget {
  const DoctorNearbySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorNearbyProvider);

    return doctorsAsync.when(
      data: (doctors) {
        if (doctors.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Aucun médecin proche trouvé.'),
          );
        }
        return ListView.builder(
          shrinkWrap: true, // <-- Important pour Column/ScrollView parent
          physics: const NeverScrollableScrollPhysics(), // <-- Désactive le scroll interne
          itemCount: doctors.length,
          itemBuilder: (context, index) => DoctorNearbyCard(
            doctor: doctors[index],
            onBook: () {
              // Action pour réserver un rendez-vous
            },
            onTap: () {
              context.push('${AppRoutes.doctorDetail}/${doctors[index].idUser}');
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}