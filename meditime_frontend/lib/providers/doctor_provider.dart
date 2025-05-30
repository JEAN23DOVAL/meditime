import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor_model.dart';
import '../services/doctor_services.dart';

final doctorServiceProvider = Provider((ref) => DoctorService());

// Provider pour les meilleurs médecins (API)
final bestDoctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final service = ref.read(doctorServiceProvider);
  return await service.fetchBestDoctors();
});

// Provider pour la liste de tous les médecins (mock ou API si besoin)
final doctorListProvider = Provider<List<Doctor>>((ref) => [
  // Tu peux remplir ici avec des objets Doctor mock pour du local/dev
  // Ou remplacer par un FutureProvider si tu veux charger depuis l'API
]);

// Providers pour la recherche et le filtre
final doctorSearchProvider = StateProvider<String>((ref) => '');
final doctorFilterProvider = StateProvider<String>((ref) => '');

// Provider pour filtrer la liste selon recherche/filtre
final filteredDoctorsProvider = Provider<List<Doctor>>((ref) {
  final doctors = ref.watch(doctorListProvider);
  final search = ref.watch(doctorSearchProvider).toLowerCase();
  final filter = ref.watch(doctorFilterProvider);

  return doctors.where((doc) {
    final matchesSearch = doc.specialite.toLowerCase().contains(search) ||
        (doc.user?.firstName?.toLowerCase().contains(search) ?? false) ||
        (doc.user?.lastName.toLowerCase().contains(search) ?? false);
    final matchesFilter = filter.isEmpty || doc.specialite == filter;
    return matchesSearch && matchesFilter;
  }).toList();
});

// Provider pour les médecins triés par proximité/ville
final doctorNearbyProvider = FutureProvider.family<List<Doctor>, String?>((ref, city) async {
  final service = ref.read(doctorServiceProvider);
  // Si tu veux utiliser la méthode fetchDoctorsByProximity, adapte-la pour prendre la ville
  return await service.fetchDoctorsByProximityWithCity(ref, city);
});