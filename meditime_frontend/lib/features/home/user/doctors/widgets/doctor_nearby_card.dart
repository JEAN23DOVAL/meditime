import 'package:flutter/material.dart';
import 'package:meditime_frontend/models/doctor_model.dart';

class DoctorNearbyCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onBook;

  const DoctorNearbyCard({super.key, required this.doctor, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final user = doctor.user;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Photo à gauche
            CircleAvatar(
              radius: 32,
              backgroundImage: user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
                  ? NetworkImage(user.profilePhoto!)
                  : null,
              child: user?.profilePhoto == null ? const Icon(Icons.person, size: 32) : null,
            ),
            const SizedBox(width: 16),
            // Infos à droite
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${(user?.firstName ?? '').trim()} ${(user?.lastName ?? '').trim()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.city ?? 'Ville inconnue',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: onBook,
                      child: const Text('Prendre RDV'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}