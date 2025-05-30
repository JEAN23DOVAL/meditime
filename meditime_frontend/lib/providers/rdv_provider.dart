import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/user/rdv/widgets/rdv_list.dart';
import '../models/rdv_model.dart';
import '../services/rdv_service.dart';

final rdvServiceProvider = Provider((ref) => RdvService());

// Ajoute ce provider family pour accepter des paramètres dynamiques
final rdvListProvider = FutureProvider.family<List<Rdv>, RdvListParams>((ref, params) async {
  final service = ref.read(rdvServiceProvider);
  // Passe les deux paramètres à la requête HTTP
  final rdvs = await service.fetchRdvs(
    patientId: params.patientId,
    doctorId: params.doctorId,
  );
  // Plus besoin de filtrer côté front ici
  return rdvs;
});

final rdvByIdProvider = FutureProvider.family<Rdv, int>((ref, id) async {
  final service = ref.read(rdvServiceProvider);
  return await service.fetchRdvById(id);
});