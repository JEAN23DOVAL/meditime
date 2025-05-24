import 'package:flutter/material.dart';
import 'package:meditime_frontend/features/home/admin/medecin/providers/medecin_provider.dart';
import 'package:meditime_frontend/features/home/admin/provider/summary_provider.dart';
import 'pdf_viewer_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/medecin.dart';
import '../services/medecin_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedecinDetailScreen extends ConsumerWidget {
  final Medecin medecin;
  const MedecinDetailScreen({super.key, required this.medecin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = medecin.status;
    final List<String> pastConsultations = []; // À remplir dynamiquement si dispo
    final List<String> upcomingConsultations = [];

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: Text(
          // Pas de prénom/nom dans ton modèle actuel, donc on affiche l'ID et la spécialité
          "Médecin #${medecin.idUser} - ${medecin.specialite}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccountStatusBanner(status),
              const SizedBox(height: 16),
              _buildDoctorDetailsCard(context),
              const SizedBox(height: 16),
              if (status == "pending") _buildPendingActions(context, ref),
              if (status == "accepted") _buildValidatedActions(context),
              if (status == "refused") _buildSuspendedActions(context),
              const SizedBox(height: 16),
              if (status == "refused") _buildSuspensionReason(medecin.adminMessage),
              const SizedBox(height: 16),
              if (status != "pending")
                _buildConsultations("Consultations passées", pastConsultations),
              const SizedBox(height: 16),
              if (status != "pending")
                _buildConsultations("Consultations à venir", upcomingConsultations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountStatusBanner(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case "pending":
        color = Colors.orange;
        text = "Compte en attente de validation";
        icon = Icons.hourglass_top;
        break;
      case "accepted":
        color = Colors.green;
        text = "Compte validé";
        icon = Icons.check_circle;
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDoctorDetailsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informations du Médecin",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            // Photo de profil (pas dans ton modèle, donc icône par défaut)
            Center(
              child: CircleAvatar(
                radius: 50,
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.person, "ID Utilisateur :", "${medecin.idUser}"),
            _infoRow(Icons.medical_services, "Spécialité :", medecin.specialite),
            _infoRow(Icons.school, "Diplômes :", medecin.diplomes),
            _infoRow(Icons.badge, "Numéro d'inscription :", medecin.numeroInscription),
            _infoRow(Icons.local_hospital, "Hôpital/Clinique :", medecin.hopital),
            _infoRow(Icons.place, "Adresse de consultation :", medecin.adresseConsultation),
            // Documents
            const SizedBox(height: 12),
            const Text(
              "Documents fournis",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            _fileTile("CNI (Recto)", medecin.cniFront, context),
            _fileTile("CNI (Verso)", medecin.cniBack, context),
            _fileTile("Certification", medecin.certification, context),
            _fileTile("CV (PDF)", medecin.cvPdf, context),
            _fileTile("Casier Judiciaire", medecin.casierJudiciaire, context),
            // Commentaire admin
            if (medecin.adminMessage != null && medecin.adminMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Commentaire de l'Administrateur",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(medecin.adminMessage!),
            ],
            const SizedBox(height: 12),
            // Dates
            _infoRow(Icons.calendar_today, "Créé le :", medecin.createdAt.toString()),
            _infoRow(Icons.update, "Mis à jour le :", medecin.updatedAt.toString()),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 22, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$label ${text ?? ''}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _fileTile(String label, String? url, BuildContext context) {
    final isImage = url != null && RegExp(r'\.(jpg|jpeg|png|webp|bmp|gif|tiff|heic)$').hasMatch(url.toLowerCase());
    final isPdf = url != null && url.toLowerCase().endsWith('.pdf');
    final isHttp = url != null && url.startsWith('http');

    return ListTile(
      leading: const Icon(Icons.insert_drive_file, color: Colors.grey),
      title: Text(label),
      trailing: (url != null && url.isNotEmpty && isHttp)
          ? TextButton(
              onPressed: () async {
                if (isPdf) {
                  final file = await _downloadFile(url, label);
                  if (file != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfViewerScreen(url: file.path),
                      ),
                    );
                  }
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

  // Télécharge un fichier et retourne un File local
  Future<File?> _downloadFile(String url, String label) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$label.pdf');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erreur téléchargement PDF: $e');
    }
    return null;
  }

  // Affiche une image dans un dialog
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

  Widget _buildPendingActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            try {
              await MedecinService().validerMedecin(medecin.id);
              ref.invalidate(medecinListProvider);
              ref.invalidate(summaryStatsProvider); // <-- AJOUT ICI
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Le compte a été validé et l'utilisateur notifié.")),
              );
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erreur : $e")),
              );
            }
          },
          icon: const Icon(Icons.check_circle, color: Colors.white),
          label: const Text("Valider le compte"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            _showRefusalDialog(context, ref);
          },
          icon: const Icon(Icons.cancel, color: Colors.white),
          label: const Text("Refuser le compte"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildValidatedActions(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: appeler ton API pour suspendre
      },
      icon: const Icon(Icons.block, color: Colors.white),
      label: const Text("Suspendre le compte"),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
    );
  }

  Widget _buildSuspendedActions(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: appeler ton API pour réactiver
      },
      icon: const Icon(Icons.refresh, color: Colors.white),
      label: const Text("Réactiver le compte"),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
    );
  }

  Widget _buildSuspensionReason(String? motif) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Motif de la suspension",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(motif ?? "Aucun motif fourni"),
        ]),
      ),
    );
  }

  Widget _buildConsultations(String title, List<String> consultations) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (consultations.isEmpty)
            const Text("Aucune consultation disponible.")
          else
            ...consultations.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text("• $c"),
                )),
        ]),
      ),
    );
  }

  void _showRefusalDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Refuser le compte",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Veuillez ajouter un commentaire pour expliquer la raison du refus :",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Ajouter un commentaire...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = _commentController.text.trim();
                if (comment.isNotEmpty) {
                  try {
                    await MedecinService().refuserMedecin(medecin.id, comment);
                    ref.invalidate(medecinListProvider);
                    ref.invalidate(summaryStatsProvider); // <-- AJOUT ICI
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Le compte a été refusé et l'utilisateur notifié.")),
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