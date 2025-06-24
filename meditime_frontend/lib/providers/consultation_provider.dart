import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/models/consutation_model.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/services/consultation_service.dart';

final consultationServiceProvider = Provider((ref) => ConsultationService());

final consultationCreationProvider = FutureProvider.autoDispose.family<ConsultationDetails, ConsultationCreationParams>((ref, params) async {
  final service = ref.read(consultationServiceProvider);
  return await service.createConsultation(
    rdvId: params.rdvId,
    patientId: params.patientId,
    doctorId: params.doctorId,
    diagnostic: params.diagnostic,
    prescription: params.prescription,
    doctorNotes: params.doctorNotes,
    files: params.files,
    token: params.token,
  );
});

final consultationByRdvProvider = FutureProvider.family<ConsultationDetails?, int>((ref, rdvId) async {
  final service = ref.read(consultationServiceProvider);
  final token = await ref.read(authProvider.notifier).getToken();
  if (token == null) return null;
  return await service.getConsultationByRdvId(rdvId: rdvId, token: token);
});

class ConsultationCreationParams {
  final int rdvId;
  final int patientId;
  final int doctorId;
  final String diagnostic;
  final String prescription;
  final String? doctorNotes;
  final List<PlatformFile> files;
  final String token;

  ConsultationCreationParams({
    required this.rdvId,
    required this.patientId,
    required this.doctorId,
    required this.diagnostic,
    required this.prescription,
    this.doctorNotes,
    required this.files,
    required this.token,
  });
}