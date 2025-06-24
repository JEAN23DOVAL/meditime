import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_drawer.dart';
import 'package:meditime_frontend/features/home/user/rdv/widgets/rdv_list.dart';
import 'package:meditime_frontend/models/rdv_model.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';

class AdminRdvListScreen extends ConsumerStatefulWidget {
  const AdminRdvListScreen({super.key});

  @override
  ConsumerState<AdminRdvListScreen> createState() => _AdminRdvListScreenState();
}

class _AdminRdvListScreenState extends ConsumerState<AdminRdvListScreen> {
  String search = '';
  String filter = '';
  String sortBy = 'date';
  String order = 'DESC';

  final searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final params = RdvListParams(
      search: search.isEmpty ? null : search,
      filter: filter.isEmpty ? 'all' : filter,
      sortBy: sortBy,
      order: order,
    );
    final rdvsAsync = ref.watch(rdvListProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tous les rendez-vous"),
        centerTitle: true,
      ),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // --- BARRE DE RECHERCHE ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(14),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (v) {
                    setState(() => search = v);
                  },
                  decoration: InputDecoration(
                    hintText: "Rechercher (nom, spécialité...)",
                    prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                    suffixIcon: search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              searchCtrl.clear();
                              setState(() => search = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  textInputAction: TextInputAction.search,
                ),
              ),
            ),
            // --- FILTRES & TRIS ---
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _FilterChip(
                    label: "Tous",
                    selected: filter == '',
                    onTap: () => setState(() => filter = ''),
                  ),
                  _FilterChip(
                    label: "À venir",
                    selected: filter == 'upcoming',
                    onTap: () => setState(() => filter = 'upcoming'),
                  ),
                  _FilterChip(
                    label: "Terminé",
                    selected: filter == 'completed',
                    onTap: () => setState(() => filter = 'completed'),
                  ),
                  _FilterChip(
                    label: "Annulé",
                    selected: filter == 'cancelled',
                    onTap: () => setState(() => filter = 'cancelled'),
                  ),
                  _FilterChip(
                    label: "Non honoré",
                    selected: filter == 'no_show',
                    onTap: () => setState(() => filter = 'no_show'),
                  ),
                  _FilterChip(
                    label: "Médecin absent",
                    selected: filter == 'doctor_no_show',
                    onTap: () => setState(() => filter = 'doctor_no_show'),
                  ),
                  const SizedBox(width: 12),
                  // --- TRIS ---
                  _SortDropdown(
                    value: sortBy,
                    onChanged: (v) => setState(() => sortBy = v!),
                  ),
                  const SizedBox(width: 8),
                  _OrderToggle(
                    order: order,
                    onChanged: (v) => setState(() => order = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // --- LISTE DES RDV ---
            Expanded(
              child: rdvsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Erreur: $e")),
                data: (rdvs) => rdvs.isEmpty
                    ? const Center(child: Text("Aucun rendez-vous trouvé.", style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: rdvs.length,
                        itemBuilder: (context, i) => _RdvAdminCard(rdv: rdvs[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- FILTRE CHIP ---
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.deepPurple)),
        selected: selected,
        selectedColor: Colors.deepPurple,
        backgroundColor: Colors.deepPurple.withOpacity(0.08),
        onSelected: (_) => onTap(),
        elevation: selected ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }
}

// --- DROPDOWN POUR LE TRI ---
class _SortDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _SortDropdown({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(10),
      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple),
      items: const [
        DropdownMenuItem(value: 'date', child: Text('Date')),
        DropdownMenuItem(value: 'created_at', child: Text('Création')),
        DropdownMenuItem(value: 'updated_at', child: Text('Modifié')),
      ],
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
    );
  }
}

// --- BOUTON ASC/DESC ---
class _OrderToggle extends StatelessWidget {
  final String order;
  final ValueChanged<String> onChanged;
  const _OrderToggle({required this.order, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        order == 'DESC' ? Icons.arrow_downward : Icons.arrow_upward,
        color: Colors.deepPurple,
      ),
      tooltip: order == 'DESC' ? 'Du plus récent' : 'Du plus ancien',
      onPressed: () => onChanged(order == 'DESC' ? 'ASC' : 'DESC'),
    );
  }
}

// --- TA CARTE RDV VALIDÉE ---
class _RdvAdminCard extends StatelessWidget {
  final Rdv rdv;
  const _RdvAdminCard({required this.rdv});

  @override
  Widget build(BuildContext context) {
    final doctor = rdv.doctor;
    final patient = rdv.patient;
    final dateStr =
        "${rdv.date.day.toString().padLeft(2, '0')}/${rdv.date.month.toString().padLeft(2, '0')}/${rdv.date.year} ${rdv.date.hour.toString().padLeft(2, '0')}:${rdv.date.minute.toString().padLeft(2, '0')}";

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go('/admin/rdvs/${rdv.id}'),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonne avatars
              Column(
                children: [
                  // Avatar médecin
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.deepPurple.withOpacity(0.13),
                    backgroundImage: doctor?.profilePhoto != null && doctor!.profilePhoto!.isNotEmpty
                        ? NetworkImage(doctor.profilePhoto!)
                        : null,
                    child: doctor?.profilePhoto == null
                        ? const Icon(Icons.person, color: Colors.deepPurple, size: 28)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  // Avatar patient
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.blueGrey.withOpacity(0.13),
                    backgroundImage: patient?.profilePhoto != null && patient!.profilePhoto!.isNotEmpty
                        ? NetworkImage(patient.profilePhoto!)
                        : null,
                    child: patient?.profilePhoto == null
                        ? const Icon(Icons.person, color: Colors.blueGrey, size: 22)
                        : null,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne nom médecin + statut à droite
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Dr. ${doctor?.firstName ?? ''} ${doctor?.lastName ?? ''}".trim().isEmpty
                                ? "Médecin inconnu"
                                : "Dr. ${doctor?.firstName ?? ''} ${doctor?.lastName ?? ''}".trim(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        _statusChip(rdv.status),
                      ],
                    ),
                    // Spécialité
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.deepPurple, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            rdv.specialty,
                            style: const TextStyle(fontSize: 15, color: Colors.deepPurple),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Patient
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blueGrey, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            patient != null
                                ? "${patient.firstName ?? ''} ${patient.lastName ?? ''}".trim().isEmpty
                                    ? "Patient inconnu"
                                    : "${patient.firstName ?? ''} ${patient.lastName ?? ''}".trim()
                                : "Patient inconnu",
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    // Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateStr,
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
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
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Chip(
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
      ),
    );
  }
}