import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meditime_frontend/models/rdv_model.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_drawer.dart';

class AdminRdvDetailScreen extends ConsumerWidget {
  final int rdvId;
  const AdminRdvDetailScreen({super.key, required this.rdvId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rdvAsync = ref.watch(rdvDetailsProvider(rdvId));
    final actionState = ref.watch(rdvActionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du rendez-vous"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/rdvs'),
        ),
      ),
      drawer: const AdminDrawer(),
      body: rdvAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur: $e")),
        data: (rdv) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header avec avatars et statut ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.deepPurple.withOpacity(0.13),
                    backgroundImage: rdv.doctor?.profilePhoto != null && rdv.doctor!.profilePhoto!.isNotEmpty
                        ? NetworkImage(rdv.doctor!.profilePhoto!)
                        : null,
                    child: rdv.doctor?.profilePhoto == null
                        ? const Icon(Icons.person, color: Colors.deepPurple, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blueGrey.withOpacity(0.13),
                    backgroundImage: rdv.patient?.profilePhoto != null && rdv.patient!.profilePhoto!.isNotEmpty
                        ? NetworkImage(rdv.patient!.profilePhoto!)
                        : null,
                    child: rdv.patient?.profilePhoto == null
                        ? const Icon(Icons.person, color: Colors.blueGrey, size: 24)
                        : null,
                  ),
                  const Spacer(),
                  _statusChip(rdv.status),
                ],
              ),
              const SizedBox(height: 24),
              // --- Infos principales ---
              _InfoRow(
                icon: Icons.calendar_today,
                label: "Date",
                value: DateFormat('dd/MM/yyyy HH:mm').format(rdv.date),
              ),
              _InfoRow(
                icon: Icons.stars,
                label: "Spécialité",
                value: rdv.specialty,
              ),
              _InfoRow(
                icon: Icons.timer,
                label: "Durée",
                value: "${rdv.durationMinutes} min",
              ),
              _InfoRow(
                icon: Icons.description,
                label: "Motif",
                value: rdv.motif ?? "-",
              ),
              const Divider(height: 32),
              // --- Patient ---
              const Text("Patient", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.person,
                label: "Nom",
                value: "${rdv.patient?.firstName ?? ''} ${rdv.patient?.lastName ?? ''}".trim(),
              ),
              _InfoRow(
                icon: Icons.email,
                label: "Email",
                value: rdv.patient?.email ?? "-",
              ),
              _InfoRow(
                icon: Icons.location_city,
                label: "Ville",
                value: rdv.patient?.city ?? "-",
              ),
              const Divider(height: 32),
              // --- Médecin ---
              const Text("Médecin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.person,
                label: "Nom",
                value: "Dr. ${rdv.doctor?.firstName ?? ''} ${rdv.doctor?.lastName ?? ''}".trim(),
              ),
              _InfoRow(
                icon: Icons.email,
                label: "Email",
                value: rdv.doctor?.email ?? "-",
              ),
              _InfoRow(
                icon: Icons.location_city,
                label: "Ville",
                value: rdv.doctor?.city ?? "-",
              ),
              const Divider(height: 32),
              // --- Dates système ---
              _InfoRow(
                icon: Icons.event,
                label: "Créé le",
                value: DateFormat('dd/MM/yyyy HH:mm').format(rdv.createdAt),
              ),
              _InfoRow(
                icon: Icons.update,
                label: "Modifié le",
                value: DateFormat('dd/MM/yyyy HH:mm').format(rdv.updatedAt),
              ),
              const SizedBox(height: 32),
              // --- Actions admin scrollables ---
              if (actionState.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      const SizedBox(width: 4),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: const Text("Annuler"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: rdv.status == 'upcoming' || rdv.status == 'pending'
                            ? () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Annuler le RDV ?"),
                                    content: const Text("Cette action notifiera le patient et le médecin."),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text("Non"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text("Oui, annuler"),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    await ref.read(rdvActionProvider.notifier).cancel(rdv.id);
                                    ref.invalidate(rdvDetailsProvider(rdv.id));
                                    ref.invalidate(rdvListProvider);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Rendez-vous annulé.")),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Erreur : $e")),
                                    );
                                  }
                                }
                              }
                            : null,
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text("Supprimer"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Supprimer le RDV ?"),
                              content: const Text("Cette action est irréversible."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Annuler"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Supprimer"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await ref.read(rdvServiceProvider).deleteRdv(rdv.id);
                              ref.invalidate(rdvListProvider);
                              if (context.mounted) {
                                context.go('/admin/rdvs');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Rendez-vous supprimé.")),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erreur : $e")),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text("Éditer"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                        onPressed: () {
                          // TODO: Naviguer vers une page/modale d'édition du RDV
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Édition à implémenter")),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'upcoming':
        color = Colors.blue;
        label = 'À venir';
        icon = Icons.event;
        break;
      case 'pending':
        color = Colors.orange;
        label = 'En attente';
        icon = Icons.hourglass_empty;
        break;
      case 'completed':
        color = Colors.green;
        label = 'Terminé';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Annulé';
        icon = Icons.cancel;
        break;
      case 'no_show':
        color = Colors.orange;
        label = 'Non honoré';
        icon = Icons.block;
        break;
      case 'doctor_no_show':
        color = Colors.deepOrange;
        label = 'Médecin absent';
        icon = Icons.person_off;
        break;
      case 'expired':
        color = Colors.grey;
        label = 'Expiré';
        icon = Icons.schedule;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.help;
    }
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text("$label : ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}