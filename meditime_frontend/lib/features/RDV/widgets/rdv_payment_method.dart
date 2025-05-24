import 'package:flutter/material.dart';

class RdvPaymentMethod extends StatelessWidget {
  final double amount;
  const RdvPaymentMethod({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    // À remplacer par une vraie logique de paiement
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Montant à payer (min 30%) : ${amount.toStringAsFixed(2)} €'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Moyen de paiement'),
            items: const [
              DropdownMenuItem(value: 'card', child: Text('Carte bancaire')),
              DropdownMenuItem(value: 'mobile', child: Text('Mobile Money')),
            ],
            onChanged: (v) {},
            validator: (v) => v == null ? 'Sélectionnez un moyen de paiement' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Valider le paiement ici
            },
            child: const Text('Payer le RDV'),
          ),
        ],
      ),
    );
  }
}