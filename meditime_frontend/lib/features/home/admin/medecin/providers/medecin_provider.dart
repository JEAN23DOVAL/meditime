import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medecin.dart';
import '../services/medecin_service.dart';

final medecinServiceProvider = Provider((ref) => MedecinService());

final medecinListProvider = FutureProvider<List<Medecin>>((ref) async {
  return MedecinService().fetchAllMedecins();
});

final medecinSearchProvider = StateProvider<String>((ref) => '');
final medecinFilterProvider = StateProvider<String>((ref) => '');

final filteredMedecinsProvider = Provider<List<Medecin>>((ref) {
  final medecinsAsync = ref.watch(medecinListProvider);
  final search = ref.watch(medecinSearchProvider).toLowerCase();
  final filter = ref.watch(medecinFilterProvider);

  return medecinsAsync.maybeWhen(
    data: (medecins) {
      var filtered = medecins;
      if (filter.isNotEmpty) {
        filtered = filtered.where((m) => m.status == filter).toList();
      }
      if (search.isNotEmpty) {
        filtered = filtered.where((m) =>
          m.specialite.toLowerCase().contains(search) ||
          m.hopital.toLowerCase().contains(search) ||
          m.diplomes.toLowerCase().contains(search)
        ).toList();
      }
      return filtered;
    },
    orElse: () => [],
  );
});