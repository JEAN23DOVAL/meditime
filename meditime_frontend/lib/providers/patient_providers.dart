import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/services/patient_services.dart';

final patientAdminServiceProvider = Provider((ref) => PatientAdminService());

final patientListProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final service = ref.read(patientAdminServiceProvider);
  return await service.fetchPatients(
    search: params['search'],
    status: params['status'],
    limit: params['limit'] ?? 20,
    offset: params['offset'] ?? 0,
    sort: params['sort'] ?? 'createdAt',
    order: params['order'] ?? 'DESC',
  );
});

final patientDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final service = ref.read(patientAdminServiceProvider);
  return await service.fetchPatientDetails(id);
});