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

class DoctorPage extends ConsumerStatefulWidget {
  const DoctorPage({super.key});

  @override
  ConsumerState<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends ConsumerState<DoctorPage> {
  void Function()? resetFiltersCallback;

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(advancedDoctorsProvider);

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
            onChanged: (value) {
              ref.read(doctorSearchProvider.notifier).state = value.isEmpty ? null : value;
            },
          ),
          DoctorFiltersRow(
            initialAvailable: false,
            onAvailableChanged: (value) {
              ref.read(doctorAvailableProvider.notifier).state = value;
            },
            onPriceRangeChanged: (range) {
              ref.read(doctorMinPriceProvider.notifier).state = range.start > 0 ? range.start : null;
              ref.read(doctorMaxPriceProvider.notifier).state = range.end < 100000 ? range.end : null;
            },
            onGenderChanged: (value) {
              ref.read(doctorGenderProvider.notifier).state = value;
            },
            onResetFilters: (reset) => resetFiltersCallback = reset,
          ),
          Expanded(
            child: doctorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (doctors) => DoctorList(
                doctors: doctors,
                onBook: (doctor) {
                  Navigator.pop(context, doctor);
                },
                onTap: (doctor) {
                  context.go('${AppRoutes.doctorDetail}/${doctor.idUser}');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}