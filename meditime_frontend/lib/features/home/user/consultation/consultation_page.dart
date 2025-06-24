import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/models/consutation_model.dart';
import 'package:meditime_frontend/models/rdv_model.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/providers/consultation_provider.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meditime_frontend/features/home/user/messages/widgets/message_detail_page.dart';

class ConsultationDetailsPage extends ConsumerStatefulWidget {
  final int rdvId;
  final bool canEdit;
  final bool isNewConsultation;

  const ConsultationDetailsPage({
    required this.rdvId,
    this.canEdit = false,
    this.isNewConsultation = false,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsultationDetailsPage> createState() => _ConsultationDetailsPageState();
}

class _ConsultationDetailsPageState extends ConsumerState<ConsultationDetailsPage> {
  List<PlatformFile> selectedFiles = [];

  Map<String, List<String>> formData = {
    'diagnostic': [],
    'prescription': [],
    'notes': [],
  };
  Map<String, bool> editingStates = {
    'diagnostic': false,
    'prescription': false,
    'notes': false,
  };

  @override
  Widget build(BuildContext context) {
    final rdvAsync = ref.watch(rdvDetailsProvider(widget.rdvId));
    final consultationAsync = ref.watch(consultationByRdvProvider(widget.rdvId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isNewConsultation
              ? 'Nouvelle consultation'
              : 'Détails de la consultation'
        ),
      ),
      body: rdvAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (rdv) {
          return consultationAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Erreur: $err')),
            data: (consultation) {
              if (consultation != null && (formData['diagnostic']?.isEmpty ?? true)) {
                formData['diagnostic'] = consultation.diagnostic.isNotEmpty
                    ? consultation.diagnostic.split('\n')
                    : [];
                formData['prescription'] = consultation.prescription.isNotEmpty
                    ? consultation.prescription.split('\n')
                    : [];
                formData['notes'] = (consultation.doctorNotes?.isNotEmpty ?? false)
                    ? consultation.doctorNotes!.split('\n')
                    : [];
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFixedInfoSection(rdv),
                    const Divider(height: 32),
                    _buildSectionWithEditButton(
                      title: '🔍 Diagnostic',
                      content: formData['diagnostic'],
                      isEditing: widget.isNewConsultation || (editingStates['diagnostic'] ?? false),
                      canEdit: widget.canEdit,
                      onEditPressed: () => _toggleEdit('diagnostic'),
                      onSave: (value) {
                        setState(() {
                          formData['diagnostic'] = [value];
                          editingStates['diagnostic'] = false;
                        });
                      },
                    ),
                    _buildSectionWithEditButton(
                      title: '💊 Prescription',
                      content: formData['prescription'],
                      isEditing: widget.isNewConsultation || (editingStates['prescription'] ?? false),
                      canEdit: widget.canEdit,
                      onEditPressed: () => _toggleEdit('prescription'),
                      onSave: (value) {
                        setState(() {
                          formData['prescription'] = [value];
                          editingStates['prescription'] = false;
                        });
                      },
                    ),
                    _buildSectionWithEditButton(
                      title: '📝 Notes du médecin',
                      content: formData['notes'],
                      isEditing: widget.isNewConsultation || (editingStates['notes'] ?? false),
                      canEdit: widget.canEdit,
                      onEditPressed: () => _toggleEdit('notes'),
                      onSave: (value) {
                        setState(() {
                          formData['notes'] = [value];
                          editingStates['notes'] = false;
                        });
                      },
                    ),
                    _buildAttachmentsSection(consultation?.files ?? [], canEdit: widget.canEdit),
                    if (widget.canEdit)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _saveConsultation(rdv),
                            child: Text(widget.isNewConsultation ? 'Créer' : 'Sauvegarder'),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Charger la consultation si elle existe (par rdvId)
    Future.microtask(() async {
      final container = ProviderContainer();
      final token = await container.read(authProvider.notifier).getToken();
      if (token != null) {
        final service = container.read(consultationServiceProvider);
        final consultation = await service.getConsultationByRdvId(rdvId: widget.rdvId, token: token);
        if (consultation != null) {
          setState(() {
            formData['diagnostic'] = consultation.diagnostic.isNotEmpty
                ? consultation.diagnostic.split('\n')
                : [];
            formData['prescription'] = consultation.prescription.isNotEmpty
                ? consultation.prescription.split('\n')
                : [];
            formData['notes'] = (consultation.doctorNotes?.isNotEmpty ?? false)
                ? consultation.doctorNotes!.split('\n')
                : [];
            selectedFiles = []; // Les fichiers déjà uploadés sont dans consultation.files
          });
        }
      }
    });
  }

  Future<void> _saveConsultation(Rdv rdv) async {
    final user = ref.read(authProvider);
    final isDoctor = user != null && user.role == 'doctor' && rdv.doctorId == user.idUser;
    final alreadyValidated = isDoctor ? rdv.doctorPresent != null : rdv.patientPresent != null;
    final now = DateTime.now();
    final rdvStarted = now.isAfter(rdv.date);

    if (isDoctor && !alreadyValidated && rdvStarted) {
      bool? validated;
      await showPresenceDialog(
        context: context,
        rdv: rdv,
        isDoctor: true,
        onValidate: (present, reason) async {
          await ref.read(rdvServiceProvider).markPresence(
            rdvId: rdv.id,
            present: present,
            reason: reason,
          );
          ref.invalidate(rdvDetailsProvider(rdv.id));
          ref.invalidate(rdvListProvider);
          validated = present;
          if (!present) {
            // Si le médecin refuse, bloque la sauvegarde
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vous devez participer au RDV pour sauvegarder la consultation.')),
              );
            }
          }
        },
      );
      if (validated == false) return; // Blocage si refus
    }

    try {
      final token = await ref.read(authProvider.notifier).getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur d\'authentification.')),
        );
        return;
      }

      final params = ConsultationCreationParams(
        rdvId: widget.rdvId,
        patientId: rdv.patientId,
        doctorId: rdv.doctorTableId ?? rdv.doctorId,
        diagnostic: formData['diagnostic']?.join('\n') ?? '',
        prescription: formData['prescription']?.join('\n') ?? '',
        doctorNotes: formData['notes']?.join('\n'),
        files: selectedFiles, // <-- Passe les fichiers ici
        token: token,
      );
      await ref.read(consultationCreationProvider(params).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consultation créée avec succès')),
        );
        Navigator.pop(context);
        ref.invalidate(rdvDetailsProvider(widget.rdvId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Widget _buildFixedInfoSection(Rdv rdv) {
    final String patientName = '${rdv.patient?.firstName ?? ''} ${rdv.patient?.lastName ?? ''}';
    final String doctorName = 'Dr. ${rdv.doctor?.firstName ?? ''} ${rdv.doctor?.lastName ?? ''}';
    final String doctorSpeciality = rdv.specialty ?? 'Non spécifié';
    final String dateTime = _formatDateTime(rdv.date);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('🧑‍⚕️ Patient', patientName),
            const SizedBox(height: 8),
            _buildInfoRow('🗓️ Date', dateTime),
            const SizedBox(height: 8),
            _buildInfoRow('👨‍⚕️ Médecin', '$doctorName - $doctorSpeciality'),
            const SizedBox(height: 16),
            // --- Bouton Message conditionnel ---
            Consumer(
              builder: (context, ref, _) {
                final user = ref.watch(authProvider);
                if (user == null || rdv.doctor == null || rdv.patient == null) return const SizedBox.shrink();
                // Détermine l'autre utilisateur (patient ou médecin)
                final bool isPatient = user.idUser == rdv.patient?.idUser;
                final int otherUserId = isPatient ? rdv.doctor!.idUser : rdv.patient!.idUser;
                final String otherUserName = isPatient
                    ? 'Dr. ${rdv.doctor?.firstName ?? ''} ${rdv.doctor?.lastName ?? ''}'
                    : '${rdv.patient?.firstName ?? ''} ${rdv.patient?.lastName ?? ''}';

                // Vérifie si un RDV exploitable existe (statuts autorisés)
                return FutureBuilder<bool>(
                  future: ref.read(rdvServiceProvider).hasPatientHadRdvWithDoctorFast(
                    patientId: isPatient ? user.idUser : rdv.patient!.idUser,
                    doctorId: isPatient ? rdv.doctor!.idUser : user.idUser,
                  ),
                  builder: (context, snapshot) {
                    final hasRdv = snapshot.data ?? false;
                    return Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.message, color: Colors.white),
                        label: const Text("Message"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasRdv ? Colors.deepPurple : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: hasRdv ? 6 : 0,
                          shadowColor: hasRdv ? Colors.deepPurpleAccent.withOpacity(0.3) : Colors.transparent,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: hasRdv
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MessageDetailPage(
                                      senderName: otherUserName,
                                      messageContent: '',
                                      time: '',
                                      receiverId: otherUserId,
                                    ),
                                  ),
                                );
                              }
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Messagerie indisponible"),
                                    content: const Text(
                                      "Vous devez avoir pris au moins un rendez-vous avec cette personne pour pouvoir lui envoyer un message.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à ${hour}h$minute';
  }

  Widget _buildSectionWithEditButton({
    required String title,
    required List<String>? content,
    required bool isEditing,
    required bool canEdit,
    required VoidCallback onEditPressed,
    required Function(String) onSave,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (canEdit)
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                    onPressed: () => _showAddItemDialog(title, onSave),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (content == null || content.isEmpty)
              const Text('Non renseigné')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: content.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(
                          child: Text(content[index]),
                        ),
                        if (canEdit)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _showEditItemDialog(
                              title,
                              content[index],
                              index,
                              onSave,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(String title, Function(String) onSave) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter ${title.toLowerCase()}'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Saisissez ${title.toLowerCase()}...',
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                setState(() {
                  formData[_getTitleKey(title)]?.add(textController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(String title, String currentValue, int index, Function(String) onSave) {
    final textController = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${title.toLowerCase()}'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Modifiez ${title.toLowerCase()}...',
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                setState(() {
                  formData[_getTitleKey(title)]?[index] = textController.text;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  String _getTitleKey(String title) {
    if (title.contains('Diagnostic')) return 'diagnostic';
    if (title.contains('Prescription')) return 'prescription';
    return 'notes';
  }

  void _toggleEdit(String field) {
    setState(() {
      editingStates[field] = !(editingStates[field] ?? false);
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label : ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildAttachmentsSection(List<ConsultationFile> files, {required bool canEdit}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📎 Fichiers joints', style: TextStyle(fontWeight: FontWeight.bold)),
                if (canEdit)
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                    onPressed: _pickFiles,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (files.isEmpty && selectedFiles.isEmpty)
              const Text('Aucun fichier joint'),
            ...files.map((file) => ListTile(
                leading: const Icon(Icons.description),
                title: Text(file.fileUrl.split('/').last),
                subtitle: Text(file.fileType),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () async {
                    final url = Uri.parse(file.fileUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
              )),
            ...selectedFiles.map((file) => ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(file.name),
                subtitle: const Text('À téléverser'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      selectedFiles.remove(file);
                    });
                  },
                ),
              )),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection des fichiers: $e')),
      );
    }
  }



  Future<void> showPresenceDialog({
  required BuildContext context,
  required Rdv rdv,
  required bool isDoctor,
  required void Function(bool present, String reason) onValidate,
}) async {
  final reasons = isDoctor
      ? [
          "Je n’ai pas pu venir (urgence, imprévu, etc.)",
          "J’étais là, mais le patient était absent",
          "Autre raison"
        ]
      : [
          "Je n’ai pas pu venir (empêchement, oubli, etc.)",
          "J’étais présent, mais le médecin était absent",
          "Autre raison"
        ];
  String? selectedReason;
  String? customReason;
  bool? present;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.grey[50],
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, color: Colors.blueAccent, size: 38),
            const SizedBox(height: 10),
            Text(
              "Validation de présence",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.black87),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              "Merci de confirmer votre présence à ce rendez-vous.",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(reasons.length, (i) {
                final reason = reasons[i];
                final isSelected = selectedReason == reason;
                return ChoiceChip(
                  label: Text(
                    reason,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  selected: isSelected,
                  selectedColor: Colors.blueAccent,
                  backgroundColor: Colors.grey[200],
                  onSelected: (_) {
                    setState(() {
                      // Si déjà sélectionné, on désélectionne
                      selectedReason = isSelected ? null : reason;
                      if (selectedReason != "Autre raison") customReason = null;
                    });
                  },
                  showCheckmark: false,
                  elevation: isSelected ? 2 : 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }),
            ),
            if (selectedReason == "Autre raison")
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Précisez la raison",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => customReason = v,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text("Oui, j'ai participé"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      present = true;
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text("Non"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      present = false;
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (present != null && selectedReason != null) {
    onValidate(
      present!,
      selectedReason == "Autre raison" ? (customReason ?? "Autre raison") : selectedReason!,
    );
  }
}
}