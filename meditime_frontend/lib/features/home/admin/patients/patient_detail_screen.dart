import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditime_frontend/features/home/admin/messages/admin_message_detail_page.dart';
import 'package:meditime_frontend/models/patient_model.dart';
import 'package:meditime_frontend/models/rdv_model.dart';
import 'package:meditime_frontend/models/user_model.dart';
import 'package:meditime_frontend/providers/patient_providers.dart';
import 'package:meditime_frontend/services/patient_services.dart';

class PatientDetailScreen extends ConsumerWidget {
  final int patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientDetailProvider(patientId));
    final service = ref.read(patientAdminServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche Patient'),
      ),
      body: patientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (data) {
          final patient = Patient.fromJson(data);
          final stats = data['stats'] ?? {};
          final rdvs = data['patientRdvs'] as List<dynamic>? ?? [];
          final consultations = data['consultationsAsPatient'] as List<dynamic>? ?? [];
          bool isLoading = false;

          Widget statusBanner() {
            if (patient.status == 'suspended') {
              return Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  children: const [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Ce patient est suspendu', style: TextStyle(color: Colors.red)),
                  ],
                ),
              );
            }
            if (patient.status == 'inactive') {
              return Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.orange.withOpacity(0.1),
                child: Row(
                  children: const [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Ce patient est inactif', style: TextStyle(color: Colors.orange)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              statusBanner(),
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: patient.profilePhoto != null ? NetworkImage(patient.profilePhoto!) : null,
                    child: patient.profilePhoto == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${patient.firstName ?? ''} ${patient.lastName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(patient.email),
                        Text(patient.phone ?? ''),
                        Text('Statut: ${patient.status}'),
                        if (patient.suspensionReason != null) Text('Raison: ${patient.suspensionReason}', style: const TextStyle(color: Colors.red)),
                        Text('Créé le : ${patient.createdAt != null ? DateFormat('dd/MM/yyyy').format(patient.createdAt!) : "-"}'),
                        Text('Dernière modification : ${patient.updatedAt != null ? DateFormat('dd/MM/yyyy').format(patient.updatedAt!) : "-"}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Ville: ${patient.city ?? "-"}'),
              Text('Genre: ${patient.gender ?? "-"}'),
              Text('Date de naissance: ${patient.birthDate != null ? "${patient.birthDate!.day}/${patient.birthDate!.month}/${patient.birthDate!.year}" : "-"}'),
              const Divider(height: 32),
              Text('Statistiques', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Total RDV: ${stats['totalRdvs'] ?? "-"}'),
              Text('No-show: ${stats['noShowCount'] ?? "-"}'),
              Text('Dernière connexion: ${stats['lastLogin'] ?? "-"}'),
              const Divider(height: 32),
              
              // Actions rapides
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Tooltip(
                      message: patient.status == 'suspended' ? "Réactiver le patient" : "Suspendre le patient",
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.pause_circle),
                        label: Text(patient.status == 'suspended' ? 'Réactiver' : 'Suspendre'),
                        onPressed: isLoading ? null : () async {
                          isLoading = true;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(patient.status == 'suspended' ? 'Réactiver ce patient ?' : 'Suspendre ce patient ?'),
                              content: const Text('Confirmer cette action ?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmer')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await service.togglePatientStatus(patient.idUser);
                            ref.invalidate(patientDetailProvider(patient.idUser));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(patient.status == 'suspended' ? 'Compte réactivé' : 'Compte suspendu')),
                            );
                          }
                          isLoading = false;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Tooltip(
                      message: "Réinitialiser le mot de passe",
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.lock_reset),
                        label: const Text('Reset MDP'),
                        onPressed: isLoading ? null : () async {
                          isLoading = true;
                          final tempPassword = await service.resetPatientPassword(patient.idUser);
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Mot de passe réinitialisé'),
                              content: Text('Nouveau mot de passe temporaire : $tempPassword'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          isLoading = false;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Tooltip(
                      message: "Envoyer un message",
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminMessageDetailPage(
                                message: {
                                  'receiver': {
                                    'idUser': patient.idUser,
                                    'firstName': patient.firstName,
                                    'lastName': patient.lastName,
                                    'profilePhoto': patient.profilePhoto,
                                    'role': 'patient',
                                  },
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Tooltip(
                      message: "Supprimer le patient",
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: isLoading ? null : () async {
                          isLoading = true;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Supprimer ce patient ?'),
                              content: const Text('Cette action est irréversible.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Annuler'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await service.deletePatient(patient.idUser);
                            if (context.mounted) Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Patient supprimé')),
                            );
                          }
                          isLoading = false;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _PatientRdvsSection(rdvs: rdvs),
              const Divider(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _PatientRdvsSection extends StatelessWidget {
  final List<dynamic> rdvs;
  const _PatientRdvsSection({required this.rdvs});

  @override
  Widget build(BuildContext context) {
    if (rdvs.isEmpty) {
      return const Text("Aucun rendez-vous pour ce patient.");
    }
    final now = DateTime.now();
    // On adapte le champ doctor pour le modèle
    final rdvObjs = rdvs.map((e) {
      final map = Map<String, dynamic>.from(e);
      if (map['rdvDoctor'] != null) {
        map['doctor'] = map['rdvDoctor'];
      }
      return Rdv.fromJson(map);
    }).toList();
    final upcoming = rdvObjs.where((r) => r.date.isAfter(now)).toList();
    final past = rdvObjs.where((r) => !r.date.isAfter(now)).toList();
    final sorted = [...upcoming, ...past];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Rendez-vous du patient", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final rdv = sorted[i];
              final doctor = rdv.doctor;
              return Card(
                color: rdv.date.isAfter(now) ? Colors.blue[50] : Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: doctor?.profilePhoto != null && doctor!.profilePhoto!.isNotEmpty
                                ? NetworkImage(doctor.profilePhoto!)
                                : null,
                            child: doctor?.profilePhoto == null
                                ? const Icon(Icons.person, color: Colors.blueGrey)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              doctor != null
                                  ? "Dr. ${doctor.firstName ?? ''} ${doctor.lastName ?? ''}".trim()
                                  : "Médecin inconnu",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Date : ${DateFormat('dd/MM/yyyy').format(rdv.date)}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        "Heure : ${DateFormat('HH:mm').format(rdv.date)}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info, size: 18, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          Text(
                            rdv.status,
                            style: TextStyle(
                              color: rdv.status == 'upcoming'
                                  ? Colors.blue
                                  : rdv.status == 'done'
                                      ? Colors.green
                                      : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}