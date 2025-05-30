import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/services/doctor_services.dart';

class ExtraInfoFormPage extends ConsumerStatefulWidget {
  final int doctorId;
  const ExtraInfoFormPage({super.key, required this.doctorId});

  @override
  ConsumerState<ExtraInfoFormPage> createState() => _ExtraInfoFormPageState();
}

class _ExtraInfoFormPageState extends ConsumerState<ExtraInfoFormPage> {
  final _formKey = GlobalKey<FormState>();
  int? experienceYears;
  int? pricePerHour;
  String? description;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('Compléter mes infos'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Expérience
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Années d'expérience",
                      prefixIcon: Icon(Icons.work_outline_rounded, color: Colors.blueAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.blueGrey[50],
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Champ requis";
                      final n = int.tryParse(v);
                      if (n == null || n < 0) return "Entrez un nombre positif";
                      return null;
                    },
                    onSaved: (v) => experienceYears = int.tryParse(v ?? ''),
                  ),
                  const SizedBox(height: 18),
                  // Prix par heure
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Prix par heure (FCFA)",
                      prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.blueGrey[50],
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Champ requis";
                      final n = int.tryParse(v);
                      if (n == null || n < 0) return "Entrez un nombre positif";
                      return null;
                    },
                    onSaved: (v) => pricePerHour = int.tryParse(v ?? ''),
                  ),
                  const SizedBox(height: 18),
                  // Description
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Description",
                      prefixIcon: Icon(Icons.description, color: Colors.blueAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.blueGrey[50],
                    ),
                    maxLines: 4,
                    validator: (v) => (v == null || v.isEmpty) ? "Champ requis" : null,
                    onSaved: (v) => description = v,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_alt_rounded, color: Colors.white),
                      label: const Text("Enregistrer", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState?.save();
                                setState(() => _isLoading = true);
                                try {
                                  await DoctorService().updateDoctorExtraInfo(
                                    doctorId: widget.doctorId,
                                    experienceYears: experienceYears!,
                                    pricePerHour: pricePerHour!,
                                    description: description!,
                                    ref: ref,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Informations enregistrées avec succès !'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur : ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted) setState(() => _isLoading = false);
                                }
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}