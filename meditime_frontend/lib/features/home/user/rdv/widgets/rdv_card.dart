import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditime_frontend/models/rdv_model.dart';
import 'package:meditime_frontend/models/user_model.dart';

class RdvCard extends StatelessWidget {
  final Rdv rdv;
  final User user;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const RdvCard({
    super.key,
    required this.rdv,
    required this.user,
    this.onCancel,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPatient = user.role == 'patient';
    final bool isDoctor = user.role == 'doctor';

    // Sélectionne la "personne en face" selon le contexte
    final User? otherUser = isPatient ? rdv.doctor : rdv.patient;

    // Nom à afficher
    final String displayName = otherUser != null
        ? (isPatient
            ? 'Dr. ${(otherUser.firstName ?? '').trim()} ${(otherUser.lastName ?? '').trim()}'
            : '${otherUser.firstName ?? ''} ${otherUser.lastName ?? ''}'.trim())
        : (isPatient ? 'Médecin inconnu' : 'Patient inconnu');

    // Sous-titre : spécialité (pour patient) ou motif (pour médecin, tronqué)
    final String subtitle = isPatient
        ? rdv.specialty
        : (rdv.motif != null && rdv.motif!.isNotEmpty
            ? (rdv.motif!.length > 40 ? rdv.motif!.substring(0, 40) + '...' : rdv.motif!)
            : '—');

    final String dateStr = DateFormat('EEE, d MMM yyyy - HH:mm', 'fr_FR').format(rdv.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo de profil
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: otherUser?.profilePhoto != null && otherUser!.profilePhoto!.isNotEmpty
                      ? Image.network(
                          otherUser.profilePhoto!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 16),
                // Infos principales
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          buildStatusBadge(rdv.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: isPatient ? Colors.blueAccent : Colors.deepOrange,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            buildActionButtons(context, rdv, user),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.blueGrey;
        icon = Icons.hourglass_empty;
        label = 'En attente';
        break;
      case 'upcoming':
        color = Colors.blue;
        icon = Icons.event;
        label = 'À venir';
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Terminé';
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Annulé';
        break;
      case 'no_show':
        color = Colors.orange;
        icon = Icons.block;
        label = 'Non honoré';
        break;
      case 'doctor_no_show':
        color = Colors.deepOrange;
        icon = Icons.person_off;
        label = 'Médecin absent';
        break;
      case 'expired':
        color = Colors.grey;
        icon = Icons.schedule;
        label = 'Expiré';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = status;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 14),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Widget buildActionButtons(BuildContext context, Rdv rdv, User user) {
    final isPatient = user.role == 'patient';
    final isDoctor = user.role == 'doctor';

    switch (rdv.status) {
      case 'pending':
        if (isPatient) {
          return Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                label: const Text('Annuler', style: TextStyle(color: Colors.red)),
                onPressed: onCancel,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_calendar, size: 18, color: Colors.blue),
                label: const Text('Reprogrammer', style: TextStyle(color: Colors.blue)),
                onPressed: onReschedule,
              ),
            ],
          );
        } else if (isDoctor) {
          return Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.check, size: 18, color: Colors.green),
                label: const Text('Accepter', style: TextStyle(color: Colors.green)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                label: const Text('Refuser', style: TextStyle(color: Colors.red)),
                onPressed: () {},
              ),
            ],
          );
        }
        break;
      case 'upcoming':
        if (isPatient) {
          return Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                label: const Text('Annuler', style: TextStyle(color: Colors.red)),
                onPressed: onCancel,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_calendar, size: 18, color: Colors.blue),
                label: const Text('Reprogrammer', style: TextStyle(color: Colors.blue)),
                onPressed: onReschedule,
              ),
            ],
          );
        } else if (isDoctor) {
          return Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                label: const Text('Annuler', style: TextStyle(color: Colors.red)),
                onPressed: onCancel,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.block, size: 18, color: Colors.orange),
                label: const Text('Non honoré', style: TextStyle(color: Colors.orange)),
                onPressed: () {},
              ),
            ],
          );
        }
        break;
      case 'completed':
        if (isPatient) {
          return Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.info, size: 18, color: Colors.blueGrey),
                label: const Text('Détails', style: TextStyle(color: Colors.blueGrey)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.star, size: 18, color: Colors.amber),
                label: const Text('Laisser un avis', style: TextStyle(color: Colors.amber)),
                onPressed: () {},
              ),
            ],
          );
        } else if (isDoctor) {
          return OutlinedButton.icon(
            icon: const Icon(Icons.info, size: 18, color: Colors.blueGrey),
            label: const Text('Détails', style: TextStyle(color: Colors.blueGrey)),
            onPressed: () {},
          );
        }
        break;
      case 'cancelled':
      case 'no_show':
      case 'doctor_no_show':
      case 'expired':
        if (isPatient) {
          return OutlinedButton.icon(
            icon: const Icon(Icons.edit_calendar, size: 18, color: Colors.blue),
            label: const Text('Reprogrammer', style: TextStyle(color: Colors.blue)),
            onPressed: onReschedule,
          );
        } else if (isDoctor) {
          return OutlinedButton.icon(
            icon: const Icon(Icons.info, size: 18, color: Colors.blueGrey),
            label: const Text('Détails', style: TextStyle(color: Colors.blueGrey)),
            onPressed: () {},
          );
        }
        break;
      default:
        return const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }
}