import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/admin/medecin/providers/medecin_provider.dart';
import 'package:meditime_frontend/features/home/admin/medecin/widgets/medecin_filter_chips.dart';
import 'package:meditime_frontend/features/home/admin/medecin/widgets/medecin_list.dart';
import 'package:meditime_frontend/features/home/admin/medecin/widgets/medecin_search_bar.dart';
import '../widgets/admin_drawer.dart'; // <-- Ajoute cet import

class MedecinListScreen extends ConsumerWidget {
  const MedecinListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medecins = ref.watch(filteredMedecinsProvider);
    final medecinsAsync = ref.watch(medecinListProvider);

    return Scaffold(
      drawer: const AdminDrawer(), // <-- Ajoute le drawer ici
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          "Gestion des Médecins",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        leading: Builder(
          builder: (context) => // <-- Ajoute le bouton menu
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      body: Column(
        children: [
          const MedecinSearchBar(),
          const MedecinFilterChips(),
          Expanded(
            child: medecinsAsync.when(
              data: (_) => MedecinList(medecins: medecins),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Erreur : $e")),
            ),
          ),
        ],
      ),
    );
  }
}