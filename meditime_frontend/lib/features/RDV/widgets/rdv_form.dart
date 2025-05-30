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
  String? doctorName; // Ajoute cette variable dans _RdvFormState
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
          Text("Médecin sélectionné :", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_search),
            label: Text(doctorName ?? "Choisir un médecin"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              // Navigue vers la page des médecins proches et attends le résultat
              final result = await Navigator.pushNamed(
                context,
                '/doctors/nearby', // adapte selon ta route
                arguments: {'excludeDoctorId': doctorId},
              );
              if (result != null && result is Map) {
                setState(() {
                  doctorId = result['doctorId'] as String;
                  doctorName = result['doctorName'] as String;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          RdvTimeslotPicker(
            doctorId: doctorId,
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