import 'package:meditime_frontend/core/network/dio_client.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import 'package:meditime_frontend/models/admin_model.dart';

class AdminService {
  final DioClient _dio = DioClient();

  Future<Map<String, dynamic>> getSummaryStats() async {
    final response = await _dio.dio.get(ApiConstants.adminSummaryStats);
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des statistiques');
  } 

  Future<List<AdminModel>> getAllAdmins({
    String search = '',
    String sortBy = 'createdAt',
    String order = 'DESC',
    String adminRole = 'all',
  }) async {
    final response = await _dio.dio.get(
      '${ApiConstants.admins}/search',
      queryParameters: {
        'search': search,
        'sortBy': sortBy,
        'order': order,
        'adminRole': adminRole,
      },
    );
    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List).map((e) => AdminModel.fromJson(e)).toList();
    }
    throw Exception('Erreur lors de la récupération des admins');
  }

  Future<void> createAdmin(Map<String, dynamic> data) async {
    final response = await _dio.dio.post(ApiConstants.admins, data: data);
    if (response.statusCode != 201) {
      throw Exception(response.data['message'] ?? 'Erreur lors de la création');
    }
  }

  Future<void> updateAdminRole(int id, String role) async {
    final response = await _dio.dio.patch('${ApiConstants.admins}/$id/role', data: {'adminRole': role});
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Erreur lors de la modification');
    }
  }

  Future<void> disableAdmin(int id) async {
    final response = await _dio.dio.patch('${ApiConstants.admins}/$id/disable');
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Erreur lors de la désactivation');
    }
  }
}