import 'package:flutter/material.dart';
import 'package:meditime_frontend/models/doctor_model.dart';

class DoctorDetailInfo extends StatelessWidget {
  final Doctor doctor;
  const DoctorDetailInfo({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spécialité : ${doctor.specialite}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Diplômes : ${doctor.diplomes}'),
          const SizedBox(height: 8),
          Text('Hôpital : ${doctor.hopital}'),
          // Ajoute d'autres infos ici
        ],
      ),
    );
  }
}