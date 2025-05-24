import 'package:flutter/material.dart';

class RdvDoctorPicker extends StatelessWidget {
  final void Function(String doctorId) onDoctorSelected;
  const RdvDoctorPicker({super.key, required this.onDoctorSelected});

  @override
  Widget build(BuildContext context) {
    // À remplacer par une vraie liste de médecins (provider)
    final doctors = [
      {'id': '1', 'name': 'Dr. Dupont'},
      {'id': '2', 'name': 'Dr. Martin'},
    ];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Choisir un médecin'),
      items: doctors
          .map((doc) => DropdownMenuItem(
                value: doc['id'],
                child: Text(doc['name']!),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onDoctorSelected(v);
      },
      validator: (v) => v == null ? 'Sélectionnez un médecin' : null,
    );
  }
}