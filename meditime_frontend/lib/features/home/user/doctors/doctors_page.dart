import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/doctor_filters_row.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/doctor_list.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/doctor_provider.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/doctor_search.dart';

class DoctorPage extends ConsumerWidget {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(filteredDoctorsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Rechercher un Médecin'),
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
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
              doctors: doctors,
              onBook: (doctor) {
                // Action pour réserver un rendez-vous
              },
              onTap: (doctor) {
                // Action pour afficher les détails du médecin
              },
            ),
          ),
        ],
      ),
    );
  }
}