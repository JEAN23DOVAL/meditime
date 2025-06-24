import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import 'package:meditime_frontend/core/network/dio_client.dart';
import 'package:meditime_frontend/models/consutation_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/providers/consultation_provider.dart';

class ConsultationService {
  final Dio _dio = DioClient().dio;

  Future<ConsultationDetails> createConsultation({
    required int rdvId,
    required int patientId,
    required int doctorId,
    required String diagnostic,
    required String prescription,
    String? doctorNotes,
    required List<PlatformFile> files,
    required String token,
  }) async {
    final formData = FormData();

    formData.fields
      ..add(MapEntry('rdv_id', rdvId.toString()))
      ..add(MapEntry('patient_id', patientId.toString()))
      ..add(MapEntry('doctor_id', doctorId.toString()))
      ..add(MapEntry('diagnostic', diagnostic))
      ..add(MapEntry('prescription', prescription))
      ..add(MapEntry('doctor_notes', doctorNotes ?? ''));

    for (final file in files) {
      formData.files.add(MapEntry(
        'attachments',
        await MultipartFile.fromFile(file.path!, filename: file.name),
      ));
    }

    final response = await _dio.post(
      ApiConstants.consultation,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    if (response.statusCode == 201) {
      return ConsultationDetails.fromJson(response.data['consultation']);
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de la création de la consultation');
  }

  Future<ConsultationDetails?> getConsultationByRdvId({
    required int rdvId,
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.consultationByRdvId(rdvId),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            ...ApiConstants.defaultHeaders,
          },
        ),
      );
      if (response.statusCode == 200) {
        return ConsultationDetails.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Consultation non trouvée, retourne null
        return null;
      }
      rethrow;
    }
  }
}

final consultationByRdvProvider = FutureProvider.family<ConsultationDetails?, int>((ref, rdvId) async {
  final service = ref.read(consultationServiceProvider);
  final token = await ref.read(authProvider.notifier).getToken();
  if (token == null) return null;
  return await service.getConsultationByRdvId(rdvId: rdvId, token: token);
});