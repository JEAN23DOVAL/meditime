import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditime_frontend/features/home/admin/patients/patient_detail_screen.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_drawer.dart';
import 'package:meditime_frontend/models/patient_model.dart';
import 'package:meditime_frontend/providers/patient_providers.dart';
import 'package:meditime_frontend/services/patient_services.dart';

class PatientAdminScreen extends ConsumerStatefulWidget {
  const PatientAdminScreen({super.key});

  @override
  ConsumerState<PatientAdminScreen> createState() => _PatientAdminScreenState();
}

class _PatientAdminScreenState extends ConsumerState<PatientAdminScreen> {
  String? search, status, city, gender, createdAtStart, createdAtEnd;
  int limit = 20, offset = 0;
  String sort = 'createdAt', order = 'DESC';
  bool compact = false;
  final _searchController = TextEditingController();
  Timer? _debounce;
  final Set<int> selectedIds = {};

  late Map<String, dynamic> params;

  @override
  void initState() {
    super.initState();
    params = _buildParams();
  }

  Map<String, dynamic> _buildParams() => {
    'search': search,
    'status': status,
    'city': city,
    'gender': gender,
    'createdAtStart': createdAtStart,
    'createdAtEnd': createdAtEnd,
    'limit': limit,
    'offset': offset,
    'sort': sort,
    'order': order,
  };

  void _updateParams() {
    setState(() {
      params = _buildParams();
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      search = value.trim().isEmpty ? null : value.trim();
      offset = 0;
      _updateParams();
    });
  }

  void _onFilter(String? newStatus) {
    status = newStatus;
    offset = 0;
    _updateParams();
  }

  void _onCityChanged(String? value) {
    city = value;
    offset = 0;
    _updateParams();
  }

  void _onGenderChanged(String? value) {
    gender = value;
    offset = 0;
    _updateParams();
  }

  void _onDateRangeChanged(DateTimeRange? range) {
    if (range != null) {
      createdAtStart = DateFormat('yyyy-MM-dd').format(range.start);
      createdAtEnd = DateFormat('yyyy-MM-dd').format(range.end);
    } else {
      createdAtStart = null;
      createdAtEnd = null;
    }
    offset = 0;
    _updateParams();
  }

  void _onSortChanged(String? value) {
    if (value != null) {
      sort = value;
      _updateParams();
    }
  }

  void _onOrderChanged(String? value) {
    if (value != null) {
      order = value;
      _updateParams();
    }
  }

  void _toggleCompact() {
    setState(() => compact = !compact);
  }

  void _toggleSelect(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() => selectedIds.clear());
  }

  void _bulkAction(String action) async {
    if (selectedIds.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Action groupée'),
        content: Text('Confirmer l\'action "$action" sur ${selectedIds.length} patients ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmer')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(patientAdminServiceProvider).bulkAction(selectedIds.toList(), action);
      _clearSelection();
      ref.invalidate(patientListProvider(params));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action "$action" effectuée.')));
    }
  }

  void _export(String format) async {
    await ref.read(patientAdminServiceProvider).exportPatients(format: format);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export $format lancé.')));
  }

  void _nextPage(int total) {
    if (offset + limit < total) {
      offset += limit;
      _updateParams();
    }
  }

  void _prevPage() {
    if (offset - limit >= 0) {
      offset -= limit;
      _updateParams();
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientListProvider(params));

    return Scaffold(
      drawer: const AdminDrawer(),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          "Gestion des Patients",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        actions: [
          IconButton(
            icon: Icon(compact ? Icons.view_agenda : Icons.view_list),
            tooltip: compact ? "Mode détaillé" : "Mode compact",
            onPressed: _toggleCompact,
          ),
          PopupMenuButton<String>(
            onSelected: _export,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'csv', child: Text('Exporter CSV')),
              const PopupMenuItem(value: 'pdf', child: Text('Exporter PDF')),
            ],
            icon: const Icon(Icons.download),
            tooltip: "Exporter",
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Recherche instantanée
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Rechercher par nom, email, téléphone...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onSearchChanged(_searchController.text),
                  child: const Text("Rechercher"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Filtres avancés
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text("Statut: "),
                  DropdownButton<String>(
                    value: status,
                    hint: const Text("Tous"),
                    items: const [
                      DropdownMenuItem(value: null, child: Text("Tous")),
                      DropdownMenuItem(value: "active", child: Text("Actif")),
                      DropdownMenuItem(value: "inactive", child: Text("Inactif")),
                      DropdownMenuItem(value: "pending", child: Text("En attente")),
                      DropdownMenuItem(value: "suspended", child: Text("Suspendu")),
                    ],
                    onChanged: _onFilter,
                  ),
                  const SizedBox(width: 8),
                  const Text("Ville: "),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      decoration: const InputDecoration(hintText: "Ville"),
                      onChanged: _onCityChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("Genre: "),
                  DropdownButton<String>(
                    value: gender,
                    hint: const Text("Tous"),
                    items: const [
                      DropdownMenuItem(value: null, child: Text("Tous")),
                      DropdownMenuItem(value: "male", child: Text("Homme")),
                      DropdownMenuItem(value: "female", child: Text("Femme")),
                    ],
                    onChanged: _onGenderChanged,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: const Text("Date inscription"),
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      _onDateRangeChanged(range);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tri dynamique
            Row(
              children: [
                const Text("Trier par: "),
                DropdownButton<String>(
                  value: sort,
                  items: const [
                    DropdownMenuItem(value: "createdAt", child: Text("Date d'inscription")),
                    DropdownMenuItem(value: "lastName", child: Text("Nom")),
                    DropdownMenuItem(value: "city", child: Text("Ville")),
                  ],
                  onChanged: _onSortChanged,
                ),
                const SizedBox(width: 3),
                DropdownButton<String>(
                  value: order,
                  items: const [
                    DropdownMenuItem(value: "ASC", child: Text("Ascendant")),
                    DropdownMenuItem(value: "DESC", child: Text("Descendant")),
                  ],
                  onChanged: _onOrderChanged,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Actions groupées
            if (selectedIds.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text('${selectedIds.length} sélectionné(s)'),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _bulkAction('suspend'),
                      child: const Text('Suspendre'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _bulkAction('activate'),
                      child: const Text('Réactiver'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _bulkAction('delete'),
                      child: const Text('Supprimer'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _clearSelection,
                      child: const Text('Tout désélectionner'),
                    ),
                  ],
                ),
              ),
            // Liste patients
            Expanded(
              child: patientsAsync.when(
                loading: () => ListView.builder(
                  itemCount: 8,
                  itemBuilder: (_, __) => const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: SizedBox(height: 16, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey))),
                    subtitle: SizedBox(height: 12, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey))),
                  ),
                ),
                error: (e, _) => Center(child: Text('Erreur: $e')),
                data: (data) {
                  final patients = data['patients'] as List<Patient>;
                  final total = data['count'] as int;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: patients.length,
                          itemBuilder: (context, i) {
                            final p = patients[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: p.profilePhoto != null ? NetworkImage(p.profilePhoto!) : null,
                                child: p.profilePhoto == null ? const Icon(Icons.person) : null,
                              ),
                              title: Text('${p.firstName ?? ''} ${p.lastName}'),
                              subtitle: compact
                                  ? null
                                  : Text('${p.email}\n${p.city ?? ""}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                    message: "Statut: ${p.status}",
                                    child: Text(p.status),
                                  ),
                                  Checkbox(
                                    value: selectedIds.contains(p.idUser),
                                    onChanged: (_) => _toggleSelect(p.idUser),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => PatientDetailScreen(patientId: p.idUser),
                                ));
                              },
                            );
                          },
                        ),
                      ),
                      // Pagination
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: offset > 0 ? _prevPage : null,
                          ),
                          Text('Page ${(offset ~/ limit) + 1} / ${(total / limit).ceil()} — $total patients'),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: offset + limit < total ? () => _nextPage(total) : null,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: ouvrir le formulaire d'ajout patient
        },
        child: const Icon(Icons.person_add),
        tooltip: "Ajouter un patient",
      ),
    );
  }
}