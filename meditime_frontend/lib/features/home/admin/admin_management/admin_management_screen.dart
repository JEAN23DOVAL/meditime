import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'widgets/admin_card.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_drawer.dart';
import 'package:meditime_frontend/providers/admin_provider.dart';

class AdminManagementScreen extends ConsumerStatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  ConsumerState<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends ConsumerState<AdminManagementScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final params = ref.read(adminListNotifierProvider.notifier).params;
    _searchController = TextEditingController(text: params.search);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(adminListNotifierProvider.notifier);
    final params = notifier.params;

    // Synchronise le controller si la recherche change (ex: reset)
    if (_searchController.text != params.search) {
      _searchController.text = params.search;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Gestion des administrateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.fetch(),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: "Ajouter un admin",
            onPressed: () {
              // Ouvre le formulaire d'ajout (à implémenter)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Barre de recherche
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Rechercher par nom ou email...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (v) => notifier.updateParams(params.copyWith(search: v)),
            ),
            const SizedBox(height: 12),
            // 2. Filtres et tris sur une seule ligne, scrollable
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  DropdownButton<String>(
                    value: params.adminRole,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tous')),
                      DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'moderator', child: Text('Modérateur')),
                    ],
                    onChanged: (v) => notifier.updateParams(params.copyWith(adminRole: v)),
                    underline: const SizedBox(),
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: params.sortBy,
                    items: const [
                      DropdownMenuItem(value: 'createdAt', child: Text("Date d'inscription")),
                      DropdownMenuItem(value: 'lastName', child: Text("Nom")),
                      DropdownMenuItem(value: 'firstName', child: Text("Prénom")),
                      DropdownMenuItem(value: 'email', child: Text("Email")),
                      DropdownMenuItem(value: 'adminRole', child: Text("Rôle")),
                    ],
                    onChanged: (v) => notifier.updateParams(params.copyWith(sortBy: v)),
                    underline: const SizedBox(),
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: params.order,
                    items: const [
                      DropdownMenuItem(value: 'ASC', child: Text("Ascendant")),
                      DropdownMenuItem(value: 'DESC', child: Text("Descendant")),
                    ],
                    onChanged: (v) => notifier.updateParams(params.copyWith(order: v)),
                    underline: const SizedBox(),
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 3. Liste des admins (seulement elle se rebuild)
            const Expanded(child: _AdminListSection()),
          ],
        ),
      ),
    );
  }
}

// Ce widget ne rebuild QUE la liste, pas la page entière
class _AdminListSection extends ConsumerWidget {
  const _AdminListSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsAsync = ref.watch(adminListNotifierProvider);

    return adminsAsync.when(
      data: (admins) => admins.isEmpty
          ? const Center(child: Text('Aucun admin trouvé', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              itemCount: admins.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final admin = admins[index];
                return AdminCard(
                  admin: admin,
                  onEdit: () {
                    // Ouvre le dialog de modification de rôle
                  },
                  onDelete: () {
                    // Ouvre le dialog de confirmation de désactivation
                  },
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}