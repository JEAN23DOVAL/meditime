import 'package:dio/dio.dart';
import 'package:meditime_frontend/core/network/dio_client.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';

class DoctorApplicationService {
  final DioClient _dio = DioClient();

  Future<Response> submitDoctorApplication({
    required int idUser,
    required String specialite,
    required String diplomes,
    required String numeroInscription,
    required String hopital,
    required String adresseConsultation,
    String? cniFrontPath,
    String? cniBackPath,
    String? certificationPath,
    String? cvPdfPath,
    String? casierJudiciairePath,
  }) async {
    final formData = FormData.fromMap({
  'idUser': idUser,
  'specialite': specialite,
  'diplomes': diplomes,
  'numeroInscription': numeroInscription, // ⚠️
  'hopital': hopital,
  'adresseConsultation': adresseConsultation, // ⚠️
  if (cniFrontPath != null)
    'cniFront': await MultipartFile.fromFile(cniFrontPath),
  if (cniBackPath != null)
    'cniBack': await MultipartFile.fromFile(cniBackPath),
  if (certificationPath != null)
    'certification': await MultipartFile.fromFile(certificationPath),
  if (cvPdfPath != null)
    'cvPdf': await MultipartFile.fromFile(cvPdfPath),
  if (casierJudiciairePath != null)
    'casierJudiciaire': await MultipartFile.fromFile(casierJudiciairePath),
});

    return await _dio.dio.post(ApiConstants.doctorApplicationSubmit, data: formData);
  }

  Future<Map<String, dynamic>?> getLastApplication(int idUser) async {
  try {
    final response = await _dio.dio.get('${ApiConstants.doctorApplicationLast}/$idUser');
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    return null;
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      // Cas normal : aucune demande trouvée
      return null;
    }
    rethrow;
  }
}
}