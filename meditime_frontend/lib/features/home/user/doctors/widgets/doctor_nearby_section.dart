import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/providers/doctor_nearby_provider.dart';
import 'doctor_nearby_card.dart';

class DoctorNearbySection extends ConsumerWidget {
  const DoctorNearbySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorNearbyProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 350, // Ajuste selon ton design
      child: doctorsAsync.when(
        data: (doctors) => ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) => DoctorNearbyCard(
            doctor: doctors[index],
            onBook: () {
              // Navigue vers la page de prise de RDV ou affiche un dialog
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}