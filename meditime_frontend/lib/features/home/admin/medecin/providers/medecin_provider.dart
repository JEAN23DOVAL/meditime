import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/models/rdv_model.dart';
import '../models/medecin.dart';
import '../services/medecin_service.dart';

final medecinServiceProvider = Provider((ref) => MedecinService());

final medecinListProvider = FutureProvider<List<Medecin>>((ref) async {
  return ref.read(medecinServiceProvider).fetchAllMedecins();
});

final medecinSearchProvider = StateProvider<String>((ref) => '');
final medecinStatusFilterProvider = StateProvider<String?>((ref) => null);

final filteredMedecinsProvider = Provider<List<Medecin>>((ref) {
  final medecinsAsync = ref.watch(medecinListProvider);
  final search = ref.watch(medecinSearchProvider).toLowerCase();
  final status = ref.watch(medecinStatusFilterProvider);

  return medecinsAsync.maybeWhen(
    data: (medecins) {
      var filtered = medecins;
      if (status != null && status.isNotEmpty) {
        filtered = filtered.where((m) => m.status == status).toList();
      }
      if (search.isNotEmpty) {
        filtered = filtered.where((m) =>
          (m.user?.firstName?.toLowerCase().contains(search) ?? false) ||
          (m.user?.lastName?.toLowerCase().contains(search) ?? false) ||
          m.specialite.toLowerCase().contains(search) ||
          m.hopital.toLowerCase().contains(search) ||
          m.diplomes.toLowerCase().contains(search) ||
          m.numeroInscription.toLowerCase().contains(search)
        ).toList();
      }
      return filtered;
    },
    orElse: () => [],
  );
});

final doctorRdvsProvider = FutureProvider.family<List<Rdv>, int>((ref, idUser) async {
  return ref.read(medecinServiceProvider).fetchDoctorRdvs(idUser);
});