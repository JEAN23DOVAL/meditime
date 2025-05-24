import 'package:flutter/material.dart';

class RdvSummaryCard extends StatelessWidget {
  const RdvSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // À remplacer par les vraies infos du RDV
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Résumé du rendez-vous', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Médecin : Dr. Dupont'),
            Text('Date : 2025-05-22 14:00'),
            Text('Motif : Consultation générale'),
            // Ajoute d’autres infos utiles ici
          ],
        ),
      ),
    );
  }
}