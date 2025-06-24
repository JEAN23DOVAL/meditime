import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/features/home/admin/messages/admin_message_detail_page.dart';
import 'package:meditime_frontend/models/rdv_model.dart';
import 'package:meditime_frontend/models/user_model.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UpcomingRdvCard extends StatelessWidget {
  final Rdv rdv;
  final User currentUser;
  final VoidCallback onMessage;

  const UpcomingRdvCard({
    super.key,
    required this.rdv,
    required this.currentUser,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Détermine le "côté" du rdv
    final bool isPatient = currentUser.idUser == rdv.patientId;
    final User? other = isPatient ? rdv.doctor : rdv.patient;
    final String roleLabel = isPatient ? "Médecin" : "Patient";
    final String subtitle = isPatient
        ? (rdv.specialty) // Utilise le champ specialty du RDV
        : (rdv.motif ?? '');

    // Date et heure
    final date = rdv.date;
    final dateStr = DateFormat('EEEE, d MMMM', 'fr_FR').format(date);
    final startTime = DateFormat('HH:mm').format(date);
    final endTime = DateFormat('HH:mm').format(date.add(const Duration(hours: 1)));

    return Card(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Photo profil
                CircleAvatar(
                  radius: 28,
                  backgroundImage: (other != null && other.profilePhoto != null && other.profilePhoto!.isNotEmpty)
                      ? NetworkImage(other.profilePhoto!)
                      : null,
                  child: (other == null || other.profilePhoto == null || other.profilePhoto!.isEmpty)
                      ? const Icon(Icons.person, size: 32, color: Colors.white)
                      : null,
                  backgroundColor: Colors.white24,
                ),
                const SizedBox(width: 14),
                // Infos nom + spécialité/motif
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        other != null
                            ? isPatient
                                ? "Dr. ${(other.firstName ?? '').trim()} ${(other.lastName ?? '').trim()}"
                                : "${(other.firstName ?? '').trim()} ${(other.lastName ?? '').trim()}"
                            : "Utilisateur inconnu",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Bouton message
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.white),
                  tooltip: "Envoyer un message",
                  onPressed: () {
                    final otherUser = other;
                    if (otherUser != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AdminMessageDetailPage(
                            message: {
                              'receiver': {
                                'idUser': otherUser.idUser,
                                'firstName': otherUser.firstName,
                                'lastName': otherUser.lastName,
                                'profilePhoto': otherUser.profilePhoto,
                                'role': otherUser.role,
                              },
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Ligne date et heure
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              child: Row(
                children: [
                  Icon(MdiIcons.calendar, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    dateStr[0].toUpperCase() + dateStr.substring(1),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 10),
                  Icon(MdiIcons.clockOutline, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "$startTime - $endTime",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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