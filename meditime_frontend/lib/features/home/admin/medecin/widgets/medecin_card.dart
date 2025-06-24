import 'package:flutter/material.dart';
import '../models/medecin.dart';
import '../details/medecin_detail_screen.dart';

class MedecinCard extends StatelessWidget {
  final Medecin medecin;
  final VoidCallback? onTap;

  const MedecinCard({required this.medecin, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final user = medecin.user;
    final statusColor = {
      'pending': Colors.orange,
      'accepted': Colors.green,
      'refused': Colors.red,
    }[medecin.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap ??
            () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MedecinDetailScreen(medecin: medecin),
                  ),
                ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: statusColor.withOpacity(0.15),
                backgroundImage: user?.profilePhoto != null
                    ? NetworkImage(user!.profilePhoto!)
                    : null,
                child: user?.profilePhoto == null
                    ? Icon(Icons.person, color: statusColor, size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user?.firstName ?? ''} ${user?.lastName ?? ''}".trim().isEmpty
                          ? "Utilisateur #${medecin.idUser}"
                          : "${user?.firstName ?? ''} ${user?.lastName ?? ''}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      medecin.specialite,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      medecin.hopital,
                      style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      medecin.status == 'pending'
                          ? Icons.hourglass_top
                          : medecin.status == 'accepted'
                              ? Icons.verified
                              : medecin.status == 'refused'
                                  ? Icons.block
                                  : Icons.help,
                      color: statusColor,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      medecin.status == 'pending'
                          ? "En attente"
                          : medecin.status == 'accepted'
                              ? "Validé"
                              : medecin.status == 'refused'
                                  ? "Refusé"
                                  : "Inconnu",
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}