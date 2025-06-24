import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/admin/medecin/details/pdf_viewer_screen.dart';
import 'package:meditime_frontend/features/home/admin/messages/admin_message_detail_page.dart';
import '../models/medecin.dart';
import '../services/medecin_service.dart';
import '../providers/medecin_provider.dart';
import 'package:intl/intl.dart';

class MedecinDetailScreen extends ConsumerWidget {
  final Medecin medecin;
  const MedecinDetailScreen({super.key, required this.medecin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = medecin.status;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(medecin),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _StatusBanner(status: status),
          const SizedBox(height: 18),
          _ProfileSection(medecin: medecin),
          const SizedBox(height: 18),
          _InfoSection(medecin: medecin),
          const SizedBox(height: 18),
          _DocumentsSection(medecin: medecin),
          if (status == 'pending') ...[
            const SizedBox(height: 24),
            _PendingActions(medecin: medecin),
          ],
          if (status == 'accepted') ...[
            const SizedBox(height: 24),
            _AcceptedActions(medecin: medecin),
          ],
          if (status == 'refused') ...[
            const SizedBox(height: 24),
            _RefusedBanner(medecin: medecin),
          ],
          const SizedBox(height: 24),
          _DatesSection(medecin: medecin),
          const SizedBox(height: 24),
          _DoctorRdvsSection(doctorIdUser: medecin.idUser),
          const SizedBox(height: 24),
          _ActionsBar(medecin: medecin),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getTitle(Medecin medecin) {
    final user = medecin.user;
    final name = "${user?.firstName ?? ''} ${user?.lastName ?? ''}".trim();
    return name.isNotEmpty
        ? "Dr. $name"
        : "Médecin #${medecin.idUser}";
  }
}

// --- STATUS BANNER ---
class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;
    switch (status) {
      case "pending":
        color = Colors.orange;
        text = "En attente de validation";
        icon = Icons.hourglass_top;
        break;
      case "accepted":
        color = Colors.green;
        text = "Compte validé";
        icon = Icons.verified;
        break;
      case "refused":
        color = Colors.red;
        text = "Compte refusé";
        icon = Icons.block;
        break;
      default:
        color = Colors.grey;
        text = "Statut inconnu";
        icon = Icons.help;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

// --- PROFILE SECTION ---
class _ProfileSection extends StatelessWidget {
  final Medecin medecin;
  const _ProfileSection({required this.medecin});

  @override
  Widget build(BuildContext context) {
    final user = medecin.user;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: Colors.blueGrey.withOpacity(0.10),
              backgroundImage: user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
                  ? NetworkImage(user.profilePhoto!)
                  : null,
              child: user?.profilePhoto == null
                  ? const Icon(Icons.person, size: 40, color: Colors.blueGrey)
                  : null,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${user?.firstName ?? ''} ${user?.lastName ?? ''}".trim().isNotEmpty
                        ? "${user?.firstName ?? ''} ${user?.lastName ?? ''}"
                        : "Utilisateur #${medecin.idUser}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  if (user?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(user!.email!, style: const TextStyle(color: Colors.blueGrey, fontSize: 15)),
                  ],
                  if (user?.phone != null) ...[
                    const SizedBox(height: 2),
                    Text(user!.phone!, style: const TextStyle(color: Colors.black54, fontSize: 15)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- INFO SECTION ---
class _InfoSection extends StatelessWidget {
  final Medecin medecin;
  const _InfoSection({required this.medecin});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Informations professionnelles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 10),
            _infoRow(Icons.medical_services, "Spécialité", medecin.specialite),
            _infoRow(Icons.school, "Diplômes", medecin.diplomes),
            _infoRow(Icons.badge, "Numéro d'inscription", medecin.numeroInscription),
            _infoRow(Icons.local_hospital, "Hôpital/Clinique", medecin.hopital),
            _infoRow(Icons.place, "Adresse de consultation", medecin.adresseConsultation),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label : $value",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// --- DOCUMENTS SECTION ---
class _DocumentsSection extends StatelessWidget {
  final Medecin medecin;
  const _DocumentsSection({required this.medecin});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Documents fournis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 10),
            _fileTile(context, "CNI (Recto)", medecin.cniFront),
            _fileTile(context, "CNI (Verso)", medecin.cniBack),
            _fileTile(context, "Certification", medecin.certification),
            _fileTile(context, "CV (PDF)", medecin.cvPdf),
            _fileTile(context, "Casier Judiciaire", medecin.casierJudiciaire),
          ],
        ),
      ),
    );
  }

  Widget _fileTile(BuildContext context, String label, String? url) {
    final isImage = url != null && RegExp(r'\.(jpg|jpeg|png|webp|bmp|gif|tiff|heic)$').hasMatch(url.toLowerCase());
    final isPdf = url != null && url.toLowerCase().endsWith('.pdf');
    final isHttp = url != null && url.startsWith('http');
    return ListTile(
      leading: const Icon(Icons.insert_drive_file, color: Colors.grey),
      title: Text(label),
      trailing: (url != null && url.isNotEmpty && isHttp)
          ? TextButton(
              onPressed: () {
                if (isPdf) {
                  _openPdf(context, url);
                } else if (isImage) {
                  _showImageDialog(context, url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Type de fichier non supporté ou URL invalide")),
                  );
                }
              },
              child: const Text("Voir"),
            )
          : const Text("Non fourni", style: TextStyle(color: Colors.red)),
    );
  }

  void _openPdf(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(url: url),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// --- ACTIONS PENDING ---
class _PendingActions extends ConsumerWidget {
  final Medecin medecin;
  const _PendingActions({required this.medecin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle, color: Colors.white),
          label: const Text("Valider l'inscription"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () async {
            try {
              // await MedecinService().validerMedecin(medecin.id);
              ref.invalidate(medecinListProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Le compte a été validé.")),
              );
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erreur : $e")),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.cancel, color: Colors.white),
          label: const Text("Refuser l'inscription"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            _showRefusalDialog(context, ref);
          },
        ),
      ],
    );
  }

  void _showRefusalDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController _commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Refuser l'inscription", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Veuillez ajouter un commentaire pour expliquer la raison du refus :"),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Ajouter un commentaire...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = _commentController.text.trim();
                if (comment.isNotEmpty) {
                  try {
                    // await MedecinService().refuserMedecin(medecin.id, comment);
                    ref.invalidate(medecinListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Le compte a été refusé.")),
                    );
                    Navigator.pop(context); // Ferme la popup
                    Navigator.pop(context); // Ferme la fiche détail
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur : $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Veuillez ajouter un commentaire.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }
}

// --- ACTIONS ACCEPTED ---
class _AcceptedActions extends StatelessWidget {
  final Medecin medecin;
  const _AcceptedActions({required this.medecin});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.block, color: Colors.white),
      label: const Text("Suspendre le compte"),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      onPressed: () {
        // TODO: suspendre le compte (API)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Suspension à implémenter")),
        );
      },
    );
  }
}

// --- REFUSED BANNER ---
class _RefusedBanner extends StatelessWidget {
  final Medecin medecin;
  const _RefusedBanner({required this.medecin});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Motif du refus", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            Text(medecin.adminMessage ?? "Aucun commentaire fourni", style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

// --- DATES SECTION ---
class _DatesSection extends StatelessWidget {
  final Medecin medecin;
  const _DatesSection({required this.medecin});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _dateItem(Icons.calendar_today, "Créé le", dateFormat.format(medecin.createdAt)),
          const SizedBox(width: 24),
          _dateItem(Icons.update, "Mis à jour", dateFormat.format(medecin.updatedAt)),
        ],
      ),
    );
  }

  Widget _dateItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 6),
        Text("$label : $value", style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }
}

// --- ACTIONS BAR ---
class _ActionsBar extends ConsumerWidget {
  final Medecin medecin;
  const _ActionsBar({required this.medecin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = MedecinService();
    final status = medecin.status;
    final userStatus = medecin.user?.status;

    List<Widget> actions = [];

    if (status == 'pending') {
      actions.addAll([
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle, color: Colors.white),
          label: const Text("Valider"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () async {
            await service.validerMedecin(medecin.id);
            ref.invalidate(medecinListProvider);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Médecin validé.")));
          },
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.cancel, color: Colors.white),
          label: const Text("Refuser"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => _showRefusalDialog(context, ref),
        ),
        const SizedBox(width: 8),
      ]);
    }
    if (status == 'accepted' && userStatus != 'suspended') {
      actions.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.pause_circle, color: Colors.white),
          label: const Text("Suspendre"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () async {
            await service.suspendreMedecin(medecin.user!.idUser);
            ref.invalidate(medecinListProvider);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte suspendu.")));
          },
        ),
      );
    }
    if (userStatus == 'suspended') {
      actions.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.play_circle, color: Colors.white),
          label: const Text("Réactiver"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () async {
            await service.suspendreMedecin(medecin.user!.idUser); // même endpoint pour toggle
            ref.invalidate(medecinListProvider);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte réactivé.")));
          },
        ),
      );
    }
    actions.addAll([
      const SizedBox(width: 8),
      ElevatedButton.icon(
        icon: const Icon(Icons.lock_reset, color: Colors.white),
        label: const Text("Reset MDP"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
        onPressed: () async {
          final tempPassword = await service.resetMedecinPassword(medecin.user!.idUser);
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Mot de passe réinitialisé'),
              content: Text('Nouveau mot de passe temporaire : $tempPassword'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
              ],
            ),
          );
        },
      ),
      const SizedBox(width: 8),
      ElevatedButton.icon(
        icon: const Icon(Icons.message, color: Colors.white),
        label: const Text("Message"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        onPressed: () {
          // Navigation vers la page de message, comme pour les patients
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AdminMessageDetailPage(
                message: {
                  'receiver': {
                    'idUser': medecin.user?.idUser,
                    'firstName': medecin.user?.firstName,
                    'lastName': medecin.user?.lastName,
                    'profilePhoto': medecin.user?.profilePhoto,
                    'role': 'doctor',
                  },
                },
              ),
            ),
          );
        },
      ),
      const SizedBox(width: 8),
      ElevatedButton.icon(
        icon: const Icon(Icons.delete, color: Colors.white),
        label: const Text("Supprimer"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Supprimer ce médecin ?'),
              content: const Text('Cette action est irréversible.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
              ],
            ),
          );
          if (confirm == true) {
            await service.supprimerMedecin(medecin.id);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Médecin supprimé')));
          }
        },
      ),
    ]);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: actions),
    );
  }

  void _showRefusalDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController _commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Refuser l'inscription", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Veuillez ajouter un commentaire pour expliquer la raison du refus :"),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Ajouter un commentaire...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = _commentController.text.trim();
                if (comment.isNotEmpty) {
                  try {
                    // await MedecinService().refuserMedecin(medecin.id, comment);
                    ref.invalidate(medecinListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Le compte a été refusé.")),
                    );
                    Navigator.pop(context); // Ferme la popup
                    Navigator.pop(context); // Ferme la fiche détail
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur : $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Veuillez ajouter un commentaire.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }
}

// --- DOCTOR RDVS SECTION ---
class _DoctorRdvsSection extends ConsumerWidget {
  final int doctorIdUser;
  const _DoctorRdvsSection({required this.doctorIdUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rdvsAsync = ref.watch(doctorRdvsProvider(doctorIdUser));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Rendez-vous du médecin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        rdvsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text("Erreur : $e", style: const TextStyle(color: Colors.red)),
          data: (rdvs) {
            if (rdvs.isEmpty) {
              return const Text("Aucun rendez-vous pour ce médecin.");
            }
            // Trie : à venir d'abord, passés après
            final now = DateTime.now();
            final upcoming = rdvs.where((r) => r.date.isAfter(now)).toList();
            final past = rdvs.where((r) => !r.date.isAfter(now)).toList();
            final sorted = [...upcoming, ...past];

            return SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final rdv = sorted[i];
                  final patient = rdv.patient;
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
                                backgroundImage: patient?.profilePhoto != null && patient!.profilePhoto!.isNotEmpty
                                    ? NetworkImage(patient.profilePhoto!)
                                    : null,
                                child: patient?.profilePhoto == null
                                    ? const Icon(Icons.person, color: Colors.blueGrey)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  patient != null
                                      ? "${patient.firstName ?? ''} ${patient.lastName ?? ''}".trim()
                                      : "Patient inconnu",
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
            );
          },
        ),
      ],
    );
  }
}