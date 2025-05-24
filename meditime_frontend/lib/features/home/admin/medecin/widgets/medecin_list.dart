import 'package:flutter/material.dart';
import '../models/medecin.dart';
import 'medecin_card.dart';

class MedecinList extends StatelessWidget {
  final List<Medecin> medecins;
  const MedecinList({required this.medecins, super.key});

  @override
  Widget build(BuildContext context) {
    if (medecins.isEmpty) {
      return const Center(child: Text("Aucun médecin trouvé."));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: medecins.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return MedecinCard(medecin: medecins[index]);
      },
    );
  }
}