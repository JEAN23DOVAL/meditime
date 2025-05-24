import 'package:flutter/material.dart';
import 'package:meditime_frontend/features/home/user/doctors/widgets/doctor_provider.dart';
import 'doctor_card.dart';

class DoctorList extends StatelessWidget {
  final List<Doctor> doctors;
  final void Function(Doctor) onBook;
  final void Function(Doctor) onTap;

  const DoctorList({
    super.key,
    required this.doctors,
    required this.onBook,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const Center(child: Text('Aucun médecin trouvé.'));
    }
    return ListView.builder(
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return DoctorCard(
          doctor: doctor,
          onBook: () => onBook(doctor),
          onTap: () => onTap(doctor),
        );
      },
    );
  }
}