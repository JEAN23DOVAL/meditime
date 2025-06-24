import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/medecin_provider.dart';
import 'widgets/medecin_card.dart';
import '../widgets/admin_drawer.dart'; // <-- Ajout du drawer admin

class MedecinListScreen extends ConsumerWidget {
  const MedecinListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medecinsAsync = ref.watch(medecinListProvider);
    final medecins = ref.watch(filteredMedecinsProvider);
    final statusFilter = ref.watch(medecinStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Médecins"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        centerTitle: true,
      ),
      drawer: const AdminDrawer(), // <-- Drawer ajouté ici
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            // Recherche multi-critères
            Row(
              children: [
                Expanded(
                  child: TextField(
                    // Ne PAS utiliser de controller ici !
                    decoration: InputDecoration(
                      hintText: "Recherche (nom, spécialité, hôpital...)",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                    onChanged: (val) => ref.read(medecinSearchProvider.notifier).state = val,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: statusFilter,
                  hint: const Text("Statut"),
                  items: const [
                    DropdownMenuItem(value: null, child: Text("Tous")),
                    DropdownMenuItem(value: 'pending', child: Text("En attente")),
                    DropdownMenuItem(value: 'accepted', child: Text("Validé")),
                    DropdownMenuItem(value: 'refused', child: Text("Refusé")),
                  ],
                  onChanged: (val) => ref.read(medecinStatusFilterProvider.notifier).state = val,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: medecinsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Erreur : $e")),
                data: (_) => medecins.isEmpty
                    ? const Center(child: Text("Aucun médecin trouvé."))
                    : ListView.builder(
                        itemCount: medecins.length,
                        itemBuilder: (context, i) => MedecinCard(medecin: medecins[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}