import 'package:flutter/material.dart';
import 'package:meditime_frontend/features/home/user/rdv/widgets/rdv_bottom_sheet_content.dart';
import 'package:meditime_frontend/models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onBook;
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onBook,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = doctor.user;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: SizedBox(
        height: 110, // Augmente la hauteur de la carte
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Permet à la photo de prendre toute la hauteur
          children: [
            // Rectangle photo à gauche, occupe toute la hauteur
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Container(
                width: 90, // Augmente la largeur de la photo
                color: Colors.grey[200],
                child: user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
                    ? Image.network(
                        user.profilePhoto!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      )
                    : const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            // Infos à droite
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dr. ${(user?.firstName ?? '').trim()} ${(user?.lastName ?? '').trim()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    doctor.specialite,
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        // Ouvre le bottom sheet RDV avec le médecin pré-sélectionné
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: FractionallySizedBox(
                              heightFactor: 0.85,
                              child: RdvBottomSheetContent(selectedDoctor: doctor),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Réserver',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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