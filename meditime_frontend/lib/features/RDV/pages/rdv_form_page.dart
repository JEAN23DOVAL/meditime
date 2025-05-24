import 'package:flutter/material.dart';
import '../widgets/rdv_form.dart';

class RdvFormPage extends StatelessWidget {
  const RdvFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prendre un rendez-vous')),
      body: const RdvForm(),
    );
  }
}