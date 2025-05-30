import 'package:flutter/material.dart';
import '../../../models/rdv_model.dart';

class RdvSummaryCard extends StatelessWidget {
  final Rdv rdv;
  const RdvSummaryCard({super.key, required this.rdv});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Résumé du rendez-vous', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Médecin : Dr. ${rdv.doctor?.lastName ?? ''} ${rdv.doctor?.firstName ?? ''}'),
            Text('Date : ${rdv.date}'),
            if (rdv.motif != null) Text('Motif : ${rdv.motif}'),
            Text('Spécialité : ${rdv.specialty}'),
            Text('Durée : ${rdv.durationMinutes} min'),
            Text('Statut : ${rdv.status ?? "En attente"}'),
            // Affiche l’id doctor_table_id si besoin
            if (rdv.doctorTableId != null) Text('ID Doctor Table : ${rdv.doctorTableId}'),
          ],
        ),
      ),
    );
  }
}