import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/user/rdv/widgets/rdv_list.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import '../models/rdv_model.dart';
import '../services/rdv_service.dart';

final rdvServiceProvider = Provider((ref) => RdvService());

// Ajoute ce provider family pour accepter des paramètres dynamiques
final rdvListProvider = FutureProvider.family<List<Rdv>, RdvListParams>((ref, params) async {
  final service = ref.read(rdvServiceProvider);
  // Passe tous les paramètres à la requête HTTP
  return await service.fetchRdvs(
    patientId: params.patientId,
    doctorId: params.doctorId,
    filter: params.filter,
    search: params.search,
    sortBy: params.sortBy,
    order: params.order,
  );
});

// Ajoutez ce provider s'il n'existe pas déjà
final rdvDetailsProvider = FutureProvider.family<Rdv, int>((ref, rdvId) async {
  final service = ref.read(rdvServiceProvider);
  return await service.fetchRdvById(rdvId);
});

class RdvActionNotifier extends StateNotifier<AsyncValue<void>> {
  final RdvService _service;
  RdvActionNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> accept(int rdvId) async {
    state = const AsyncValue.loading();
    try {
      await _service.acceptRdv(rdvId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refuse(int rdvId) async {
    state = const AsyncValue.loading();
    try {
      await _service.refuseRdv(rdvId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancel(int rdvId) async {
    state = const AsyncValue.loading();
    try {
      await _service.cancelRdv(rdvId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> update(Rdv rdv) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateRdv(rdv);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final rdvActionProvider = StateNotifierProvider<RdvActionNotifier, AsyncValue<void>>(
  (ref) => RdvActionNotifier(ref.read(rdvServiceProvider)),
);

// Ajoute ces providers
final nextPatientRdvProvider = FutureProvider<Rdv?>((ref) async {
  final user = ref.read(authProvider);
  if (user == null) return null;
  final rdvs = await ref.read(rdvServiceProvider).fetchRdvs(patientId: user.idUser);
  final now = DateTime.now();
  final upcoming = rdvs.where((r) =>
    r.status == 'upcoming' && r.date.isAfter(now)
  ).toList();
  upcoming.sort((a, b) => a.date.compareTo(b.date));
  return upcoming.isNotEmpty ? upcoming.first : null;
});

final nextDoctorRdvProvider = FutureProvider<Rdv?>((ref) async {
  final user = ref.read(authProvider);
  if (user == null) return null;
  final rdvs = await ref.read(rdvServiceProvider).fetchRdvs(doctorId: user.idUser);
  final now = DateTime.now();
  final upcoming = rdvs.where((r) =>
    r.status == 'upcoming' && r.date.isAfter(now)
  ).toList();
  upcoming.sort((a, b) => a.date.compareTo(b.date));
  return upcoming.isNotEmpty ? upcoming.first : null;
});

final hasRdvWithDoctorProvider = FutureProvider.family<bool, Map<String, int>>((ref, params) async {
  final service = ref.read(rdvServiceProvider);
  return await service.hasPatientHadRdvWithDoctorFast(
    patientId: params['patientId']!,
    doctorId: params['doctorId']!,
  );
});