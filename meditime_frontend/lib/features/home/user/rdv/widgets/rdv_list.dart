import 'package:flutter/material.dart';
import 'rdv_card.dart';

class RdvList extends StatelessWidget {
  final String filter;
  final bool showPatientRdv;
  const RdvList({required this.filter, required this.showPatientRdv, super.key});

  @override
  Widget build(BuildContext context) {
    // Données simulées (remplace par Riverpod plus tard)
    final rdvs = List.generate(20, (i) {
      return {
        'title': 'RDV ${i + 1}',
        'date': '2025-05-15 14:00',
        'status': ['all', 'completed', 'ongoing', 'cancelled'][i % 4],
        'isPatient': i % 2 == 0,
      };
    });

    final filtered = rdvs.where((rdv) {
      if (filter != 'all' && rdv['status'] != filter) return false;
      if (showPatientRdv) return rdv['isPatient'] as bool;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text('Aucun rendez-vous', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final rdv = filtered[i];
        return RdvCard(
          title: rdv['title'] as String,
          date: rdv['date'] as String,
          status: rdv['status'] as String,
        );
      },
    );
  }
}