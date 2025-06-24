import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/features/home/user/messages/widgets/message_detail_page.dart';
import 'package:meditime_frontend/features/home/user/rdv/widgets/rdv_bottom_sheet_content.dart';
import 'package:meditime_frontend/models/rdv_model.dart';
import 'package:meditime_frontend/models/user_model.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';
import 'package:meditime_frontend/services/doctor_reviews_service.dart';
import 'package:meditime_frontend/widgets/formulaires/reviews_dialog.dart';

class RdvCard extends StatelessWidget {
  final Rdv rdv;
  final User user;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final WidgetRef ref; // Ajoute ceci

  const RdvCard({
    super.key,
    required this.rdv,
    required this.user,
    required this.ref, // Ajoute ceci
    this.onCancel,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPatient = user.role == 'patient';
    final bool isDoctor = user.role == 'doctor';

    // Cas particulier : le patient est aussi un médecin (il prend RDV comme patient)
    final bool isDoctorAsPatient = isDoctor && rdv.patientId == user.idUser;

    // Sélectionne la "personne en face" selon le contexte
    // Si le patient est un médecin, on affiche toujours le médecin (rdv.doctor)
    final User? otherUser = (isPatient || isDoctorAsPatient) ? rdv.doctor : rdv.patient;

    // Nom à afficher
    final String displayName = otherUser != null
        ? (isPatient || isDoctorAsPatient
            ? 'Dr. ${(otherUser.firstName ?? '').trim()} ${(otherUser.lastName ?? '').trim()}'
            : '${otherUser.firstName ?? ''} ${otherUser.lastName ?? ''}'.trim())
        : (isPatient || isDoctorAsPatient ? 'Médecin inconnu' : 'Patient inconnu');

    // Sous-titre : spécialité (pour patient) ou motif (pour médecin, tronqué)
    final String subtitle = (isPatient || isDoctorAsPatient)
        ? rdv.specialty
        : (rdv.motif != null && rdv.motif!.isNotEmpty
            ? (rdv.motif!.length > 40 ? rdv.motif!.substring(0, 40) + '...' : rdv.motif!)
            : '—');

    final String dateStr = DateFormat('EEE, d MMM yyyy - HH:mm', 'fr_FR').format(rdv.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo de profil
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: otherUser?.profilePhoto != null && otherUser!.profilePhoto!.isNotEmpty
                      ? Image.network(
                          otherUser.profilePhoto!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 16),
                // Infos principales
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          buildStatusBadge(rdv.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: isPatient ? Colors.blueAccent : Colors.deepOrange,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            buildActionButtons(context, rdv, user),
          ],
        ),
      ),
    );
  }

  Widget buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.blueGrey;
        icon = Icons.hourglass_empty;
        label = 'En attente';
        break;
      case 'upcoming':
        color = Colors.blue;
        icon = Icons.event;
        label = 'À venir';
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Terminé';
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Annulé';
        break;
      case 'no_show':
        color = Colors.orange;
        icon = Icons.block;
        label = 'Non honoré';
        break;
      case 'doctor_no_show':
        color = Colors.deepOrange;
        icon = Icons.person_off;
        label = 'Médecin absent';
        break;
      case 'both_no_show':
        color = Colors.brown;
        icon = Icons.block;
        label = 'Aucun présent';
        break;
      case 'expired':
        color = Colors.grey;
        icon = Icons.schedule;
        label = 'Expiré';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = status;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 14),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Widget buildActionButtons(BuildContext context, Rdv rdv, User user) {
    final bool isPatient = user.role == 'patient';
    final bool isDoctor = user.role == 'doctor';
    final bool isDoctorAsPatient = isDoctor && rdv.patientId == user.idUser;

    // On considère "patient" si c'est un patient OU un médecin qui est patient sur ce RDV
    final bool showPatientActions = isPatient || isDoctorAsPatient;
    final bool showDoctorActions = isDoctor && rdv.doctorId == user.idUser;

    switch (rdv.status) {
      case 'pending':
        if (showPatientActions) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Annuler',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  onPressed: () async {
                    final notifier = ref.read(rdvActionProvider.notifier);
                    await notifier.cancel(rdv.id);
                    ref.invalidate(rdvListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rendez-vous annulé')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_calendar, size: 18, color: Colors.blue),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Reprogrammer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: FractionallySizedBox(
                          heightFactor: 0.85,
                          child: RdvBottomSheetContent(
                            initialRdv: rdv, // Passe le RDV à modifier
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (showDoctorActions) {
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.check, size: 18, color: Colors.green),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Accepter',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  onPressed: () async {
                    final notifier = ref.read(rdvActionProvider.notifier);
                    await notifier.accept(rdv.id);
                    ref.invalidate(rdvListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rendez-vous accepté')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Refuser',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  onPressed: () async {
                    final notifier = ref.read(rdvActionProvider.notifier);
                    await notifier.refuse(rdv.id);
                    ref.invalidate(rdvListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rendez-vous refusé')),
                    );
                  },
                ),
              ),
            ],
          );
        }
        break;
      case 'upcoming':
        if (showPatientActions) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Annuler',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(color: Colors.red,),
                    ),
                  ),
                  onPressed: () async {
                    final notifier = ref.read(rdvActionProvider.notifier);
                    await notifier.cancel(rdv.id);
                    ref.invalidate(rdvListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rendez-vous annulé')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_calendar, size: 18, color: Colors.blue),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Reprogrammer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: FractionallySizedBox(
                          heightFactor: 0.85,
                          child: RdvBottomSheetContent(
                            initialRdv: rdv, // Passe le RDV à modifier
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (showDoctorActions) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_note, size: 18, color: Colors.blue),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Consultation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  onPressed: () {
                    context.push(
                      AppRoutes.consultationDetails.replaceAll(':rdvId', rdv.id.toString()),
                      extra: {
                        'canEdit': true,
                        'isNewConsultation': true,
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Annuler',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  onPressed: () async {
                    final notifier = ref.read(rdvActionProvider.notifier);
                    await notifier.cancel(rdv.id);
                    ref.invalidate(rdvListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rendez-vous annulé')),
                    );
                  },
                ),
              ),
            ],
          );
        }
        break;
      case 'completed':
        if (showPatientActions) {
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.info, size: 15, color: Colors.blueGrey),
                  label: const Text(
                    'Détails',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40), // Hauteur fixe, largeur auto
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
  final alreadyValidated = user.role == 'doctor'
      ? rdv.doctorPresent != null
      : rdv.patientPresent != null;
  final isDoctor = user.role == 'doctor' && rdv.doctorId == user.idUser;

  if (!alreadyValidated) {
    bool? validated;
    await showPresenceDialog(
      context: context,
      rdv: rdv,
      isDoctor: isDoctor,
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
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vous devez valider votre présence pour accéder à la consultation.')),
            );
          }
        }
      },
    );
    if (validated != true) return; // Si refus, ne pas ouvrir la page
  }

  // Si déjà validé ou vient de valider, ouvrir la page consultation
  context.push(
    AppRoutes.consultationDetails.replaceAll(':rdvId', rdv.id.toString()),
    extra: {'canEdit': isDoctor},
  );
},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.star, size: 18, color: Colors.amber),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Laisser un avis',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(color: Colors.amber),
                    ),
                  ),
                  onPressed: () async {
                    final token = await ref.read(authProvider.notifier).getToken();
                    if (token == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erreur d\'authentification. Veuillez vous reconnecter.')),
                        );
                      }
                      return;
                    }
                    // Vérifie que l'id technique doctor existe bien
                    if (rdv.doctorTableId == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erreur interne : identifiant du médecin manquant.')),
                        );
                      }
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (_) => ReviewDialog(
                        onSubmit: (rating, comment) async {
                          try {
                            await DoctorReviewService().createReview(
                              doctorId: rdv.doctorTableId!, // <-- id de la table doctor
                              rating: rating,
                              comment: comment,
                              token: token,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Avis envoyé avec succès !')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur : $e')),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (showDoctorActions) {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.info, size: 18, color: Colors.blueGrey),
              label: const Text('Détails', style: TextStyle(color: Colors.blueGrey)),
              onPressed: () {
                context.push(
                  AppRoutes.consultationDetails.replaceAll(':rdvId', rdv.id.toString()),
                  extra: {'canEdit': true}
                );
              },
            ),
          );
        }
        break;
      case 'cancelled':
      case 'no_show':
      case 'doctor_no_show':
      case 'expired':
        if (showPatientActions) {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_calendar, size: 18, color: Colors.blue),
              label: const Text('Reprogrammer', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: FractionallySizedBox(
                      heightFactor: 0.85,
                      child: RdvBottomSheetContent(
                        initialRdv: rdv, // Passe le RDV à modifier
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else if (showDoctorActions) {
          // Nouveau bouton "Recontacter le patient"
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.message, size: 18, color: Colors.deepPurple),
              label: const Text('Recontacter le patient', style: TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                final patient = rdv.patient;
                if (patient != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MessageDetailPage(
                        senderName: '${patient.firstName ?? ''} ${patient.lastName ?? ''}',
                        messageContent: '',
                        time: '',
                        receiverId: patient.idUser,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient inconnu.')),
                  );
                }
              },
            ),
          );
        }
        break;
      default:
        return const SizedBox.shrink();
    }
    return const SizedBox.shrink();
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