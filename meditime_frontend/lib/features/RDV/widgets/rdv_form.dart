import 'package:flutter/material.dart';
import 'rdv_doctor_picker.dart';
import 'rdv_timeslot_picker.dart';

class RdvForm extends StatefulWidget {
  const RdvForm({super.key});

  @override
  State<RdvForm> createState() => _RdvFormState();
}

class _RdvFormState extends State<RdvForm> {
  final _formKey = GlobalKey<FormState>();
  String? motif;
  String? doctorId;
  DateTime? timeslot;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Motif du rendez-vous'),
            onSaved: (v) => motif = v,
            validator: (v) => v == null || v.isEmpty ? 'Champ obligatoire' : null,
          ),
          const SizedBox(height: 16),
          RdvDoctorPicker(
            onDoctorSelected: (id) => doctorId = id,
          ),
          const SizedBox(height: 16),
          RdvTimeslotPicker(
            onTimeslotSelected: (date) => timeslot = date,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                // Naviguer vers la page paiement avec les infos du RDV
                // Navigator.push...
              }
            },
            child: const Text('Réserver le RDV'),
          ),
        ],
      ),
    );
  }
}