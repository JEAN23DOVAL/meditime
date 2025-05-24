import 'package:flutter/material.dart';
import '../widgets/rdv_summary_card.dart';
import '../widgets/rdv_payment_method.dart';

class RdvPaymentPage extends StatelessWidget {
  final double amount;
  const RdvPaymentPage({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement du rendez-vous')),
      body: Column(
        children: [
          const RdvSummaryCard(),
          Expanded(child: RdvPaymentMethod(amount: amount)),
        ],
      ),
    );
  }
}