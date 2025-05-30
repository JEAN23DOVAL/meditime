import 'package:dio/dio.dart';
import '../models/rdv_model.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/dio_client.dart';

class RdvService {
  final Dio _dio = DioClient().dio;

  Future<List<Rdv>> fetchRdvs({int? patientId, int? doctorId}) async {
    final query = <String, dynamic>{};
    if (patientId != null) query['patient_id'] = patientId;
    if (doctorId != null) query['doctor_id'] = doctorId;
    final response = await _dio.get(ApiConstants.rdv, queryParameters: query);
    final responseData = response.data as List;
    return responseData.map((e) => Rdv.fromJson(e)).toList();
  }

  Future<Rdv> fetchRdvById(int id) async {
    final response = await _dio.get('${ApiConstants.rdv}/$id');
    return Rdv.fromJson(response.data);
  }

  Future<Rdv> createRdv(Rdv rdv) async {
    final response = await _dio.post(ApiConstants.rdv, data: rdv.toJson());
    if (response.statusCode == 201) {
      return Rdv.fromJson(response.data);
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de la création du RDV');
  }

  Future<Rdv> updateRdv(Rdv rdv) async {
    final response = await _dio.put('${ApiConstants.rdv}/${rdv.id}', data: rdv.toJson());
    return Rdv.fromJson(response.data);
  }

  Future<void> deleteRdv(int id) async {
    await _dio.delete('${ApiConstants.rdv}/$id');
  }
}