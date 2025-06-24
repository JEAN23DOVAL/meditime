import 'package:dio/dio.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/dio_client.dart';
import '../models/patient_model.dart';

class PatientAdminService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> fetchPatients({
    String? search,
    String? status,
    String? city,
    String? gender,
    String? createdAtStart,
    String? createdAtEnd,
    int limit = 20,
    int offset = 0,
    String sort = 'createdAt',
    String order = 'DESC',
  }) async {
    final response = await _dio.get(
      ApiConstants.adminPatients,
      queryParameters: {
        'search': search,
        'status': status,
        'city': city,
        'gender': gender,
        'createdAtStart': createdAtStart,
        'createdAtEnd': createdAtEnd,
        'limit': limit,
        'offset': offset,
        'sort': sort,
        'order': order,
      }..removeWhere((k, v) => v == null),
    );
    final data = response.data;
    return {
      'count': data['count'],
      'patients': (data['patients'] as List).map((e) => Patient.fromJson(e)).toList(),
    };
  }

  Future<Map<String, dynamic>> fetchPatientDetails(int id) async {
    final response = await _dio.get(ApiConstants.adminPatientDetails(id));
    return response.data;
  }

  Future<void> togglePatientStatus(int id, {String? reason}) async {
    await _dio.patch(
      ApiConstants.adminPatientToggleStatus(id),
      data: {'reason': reason},
    );
  }

  Future<String> resetPatientPassword(int id) async {
    final response = await _dio.post(ApiConstants.adminPatientResetPassword(id));
    return response.data['tempPassword'];
  }

  Future<void> sendMessageToPatient(int id, String message) async {
    await _dio.post(ApiConstants.adminPatientSendMessage(id), data: {'content': message});
  }

  Future<Map<String, dynamic>> fetchPatientStats() async {
    final response = await _dio.get(ApiConstants.adminPatientsStats);
    return response.data;
  }

  Future<void> deletePatient(int id) async {
    await _dio.delete(ApiConstants.adminPatientDetails(id));
  }

  Future<void> exportPatients({String format = 'csv'}) async {
    final response = await _dio.get(
      '${ApiConstants.adminPatients}/export',
      queryParameters: {'format': format},
      options: Options(responseType: ResponseType.bytes),
    );
    // Gère le téléchargement côté front (web ou mobile)
  }

  Future<void> bulkAction(List<int> ids, String action, {String? reason}) async {
    await _dio.post(
      '${ApiConstants.adminPatients}/bulk-action',
      data: {'ids': ids, 'action': action, 'reason': reason},
    );
  }
}