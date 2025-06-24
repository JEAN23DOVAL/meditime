import 'package:dio/dio.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/dio_client.dart';

class AdminStatsService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> fetchStats({
    String period = 'day',
    int nb = 30,
    String? start,
    String? end,
  }) async {
    final query = {
      'period': period,
      'nb': nb,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
    };
    final response = await _dio.get(
      '${ApiConstants.baseUrl}/admin/stats',
      queryParameters: query,
    );
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des stats');
  }

  // --- EXPORT CSV ---
  Future<List<int>> exportStatsCsv(Map<String, dynamic> params) async {
    final response = await _dio.get(
      '${ApiConstants.baseUrl}/admin/stats/export-csv',
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.statusCode == 200) {
      return response.data;
    }
    throw Exception('Erreur export CSV');
  }

  // --- EXPORT PDF ---
  Future<List<int>> exportStatsPdf(Map<String, dynamic> params) async {
    final response = await _dio.get(
      '${ApiConstants.baseUrl}/admin/stats/export-pdf',
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.statusCode == 200) {
      return response.data;
    }
    throw Exception('Erreur export PDF');
  }
}