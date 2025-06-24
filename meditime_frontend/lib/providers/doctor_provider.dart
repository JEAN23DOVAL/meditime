import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/models/doctor_reviews_model.dart';
import '../models/doctor_model.dart';
import '../services/doctor_services.dart';
import 'package:meditime_frontend/services/doctor_reviews_service.dart';

// Providers pour chaque filtre
final doctorSearchProvider = StateProvider<String?>((ref) => null);
final doctorAvailableProvider = StateProvider<bool?>((ref) => null);
final doctorMinPriceProvider = StateProvider<double?>((ref) => null);
final doctorMaxPriceProvider = StateProvider<double?>((ref) => null);
final doctorGenderProvider = StateProvider<String?>((ref) => null);

// Provider pour la recherche avancée
final advancedDoctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final service = ref.read(doctorServiceProvider);
  final search = ref.watch(doctorSearchProvider);
  final available = ref.watch(doctorAvailableProvider);
  final minPrice = ref.watch(doctorMinPriceProvider);
  final maxPrice = ref.watch(doctorMaxPriceProvider);
  final gender = ref.watch(doctorGenderProvider);

  if (search == null &&
      available == null &&
      minPrice == null &&
      maxPrice == null &&
      gender == null) {
    return await service.fetchBestDoctors();
  }

  return await service.searchDoctors(
    search: search,
    available: available,
    minPrice: minPrice,
    maxPrice: maxPrice,
    gender: gender,
  );
});

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

final doctorReviewsProvider = FutureProvider.family<List<DoctorReview>, int>((ref, doctorId) async {
  final service = ref.read(doctorReviewServiceProvider);
  return await service.fetchReviewsByDoctor(doctorId);
});

final doctorReviewServiceProvider = Provider<DoctorReviewService>((ref) => DoctorReviewService());