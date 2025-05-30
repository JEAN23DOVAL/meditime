import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/doctor_filters_row.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/doctor_list.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/doctor_search.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/providers/doctor_provider.dart';

class DoctorPage extends ConsumerWidget {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);
    final args = state.extra as Map?;
    final patientCity = args?['patientCity'] as String?;
    final excludeDoctorId = args?['excludeDoctorId'] as int?;

    // Récupère l'utilisateur connecté
    final user = ref.watch(authProvider);

    // Utilise le provider asynchrone pour charger les médecins triés
    final doctorsAsync = ref.watch(doctorNearbyProvider(patientCity));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Rechercher un Médecin'),
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        elevation: 0,
      ),
      body: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (doctors) {
          // Exclure le médecin connecté si besoin
          final filteredDoctors = doctors.where((d) {
            // Exclure si l'utilisateur est médecin et que son idUser correspond
            if (user != null && user.role == 'doctor' && d.idUser == user.idUser) return false;
            // Exclure aussi si excludeDoctorId est passé en argument
            if (excludeDoctorId != null && d.idUser == excludeDoctorId) return false;
            return true;
          }).toList();

          return Column(
            children: [
              DoctorSearchBar(
                onChanged: (value) => ref.read(doctorSearchProvider.notifier).state = value,
              ),
              DoctorFiltersRow(
                onFilterSelected: (filter) => ref.read(doctorFilterProvider.notifier).state = filter,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DoctorList(
                  doctors: filteredDoctors,
                  onBook: (doctor) {
                    Navigator.pop(context, doctor);
                  },
                  onTap: (doctor) {
                    context.go('${AppRoutes.doctorDetail}/${doctor.idUser}');
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}