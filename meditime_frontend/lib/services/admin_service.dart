import 'package:meditime_frontend/core/network/dio_client.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';

class AdminService {
  final DioClient _dio = DioClient();

  Future<Map<String, dynamic>> getSummaryStats() async {
    final response = await _dio.dio.get(ApiConstants.adminSummaryStats);
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des statistiques');
  } 
}