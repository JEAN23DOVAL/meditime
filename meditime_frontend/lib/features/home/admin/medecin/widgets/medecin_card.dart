import 'package:flutter/material.dart';
import '../models/medecin.dart';
import '../details/medecin_detail_screen.dart';

class MedecinCard extends StatelessWidget {
  final Medecin medecin;
  const MedecinCard({required this.medecin, super.key});

  @override
  Widget build(BuildContext context) {
    final status = medecin.status;
    final icon = status == 'pending'
        ? Icons.watch_later
        : status == 'accepted'
            ? Icons.check_circle
            : Icons.block;
    final color = status == 'pending'
        ? Colors.orange
        : status == 'accepted'
            ? Colors.green
            : Colors.red;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedecinDetailScreen(medecin: medecin),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ID: ${medecin.idUser} | ${medecin.specialite}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text("Statut : ${medecin.status}",
                        style: TextStyle(color: color)),
                    const SizedBox(height: 2),
                    Text("Hôpital : ${medecin.hopital}",
                        style: TextStyle(color: Colors.grey[700])),
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