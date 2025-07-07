import 'package:dio/dio.dart';
import '../models/rdv_model.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/dio_client.dart';

class RdvService {
  final Dio _dio = DioClient().dio;

  Future<List<Rdv>> fetchRdvs({
    int? patientId,
    int? doctorId,
    String? filter,
    String? search,
    String? sortBy,
    String? order,
  }) async {
    final query = <String, dynamic>{};
    if (patientId != null) query['patient_id'] = patientId;
    if (doctorId != null) query['doctor_id'] = doctorId;
    // Correction ici : pour "no_show", envoie tous les statuts d'absence
    if (filter == 'no_show') {
      query['status'] = 'no_show,doctor_no_show,both_no_show,expired';
    } else if (filter != null && filter != 'all' && filter != 'upcoming') {
      query['status'] = filter;
    }
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (sortBy != null) query['sortBy'] = sortBy;
    if (order != null) query['order'] = order;
    final response = await _dio.get(ApiConstants.rdv, queryParameters: query);
    final responseData = response.data as List;
    return responseData.map((e) => Rdv.fromJson(e)).toList();
  }

  Future<Rdv> fetchRdvById(int id) async {
    final response = await _dio.get('${ApiConstants.rdv}/$id');
    return Rdv.fromJson(response.data);
  }

  /* Future<Map<String, dynamic>> createRdv(Rdv rdv) async {
    final response = await _dio.post(ApiConstants.rdv, data: rdv.toJson());
    if (response.statusCode == 201) {
      final data = response.data;
      return {
        'paymentUrl': data['paymentUrl'],
        'rdv': data['rdv'] != null ? Rdv.fromJson(data['rdv']) : null,
      };
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de la création du RDV');
  } */

  Future<Map<String, dynamic>> createRdv(Rdv rdv) async {
    final response = await _dio.post(ApiConstants.paymentInitiate, data: rdv.toJson());
    if (response.statusCode == 200) {
      final data = response.data;
      return {
        'paymentUrl': data['paymentUrl'],
        'transactionId': data['transactionId'],
      };
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de la création du paiement');
  }

  Future<Rdv> updateRdv(Rdv rdv) async {
    final response = await _dio.put('${ApiConstants.rdv}/${rdv.id}', data: rdv.toJson());
    return Rdv.fromJson(response.data);
  }

  Future<void> deleteRdv(int id) async {
    await _dio.delete('${ApiConstants.rdv}/$id');
  }

  Future<Rdv> acceptRdv(int rdvId) async {
    final response = await _dio.patch('${ApiConstants.rdv}/$rdvId/accept');
    if (response.statusCode == 200) {
      return Rdv.fromJson(response.data['rdv'] ?? response.data);
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de l\'acceptation du RDV');
  }

  Future<Rdv> refuseRdv(int rdvId) async {
    final response = await _dio.patch('${ApiConstants.rdv}/$rdvId/refuse');
    if (response.statusCode == 200) {
      return Rdv.fromJson(response.data['rdv'] ?? response.data);
    }
    throw Exception(response.data['message'] ?? 'Erreur lors du refus du RDV');
  }

  Future<Rdv> cancelRdv(int rdvId) async {
    final response = await _dio.patch('${ApiConstants.rdv}/$rdvId/cancel');
    if (response.statusCode == 200) {
      return Rdv.fromJson(response.data['rdv'] ?? response.data);
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de l\'annulation du RDV');
  }

  Future<bool> hasPatientHadRdvWithDoctorFast({
    required int patientId,
    required int doctorId,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.baseUrl}/rdv/has-between',
      queryParameters: {
        'patient_id': patientId,
        'doctor_id': doctorId,
      },
    );
    if (response.statusCode == 200 && response.data != null) {
      return response.data['exists'] == true;
    }
    throw Exception('Erreur lors de la vérification RDV');
  }

  Future<void> markPresence({
    required int rdvId,
    required bool present,
    required String reason,
  }) async {
    await _dio.patch('${ApiConstants.rdv}/$rdvId/mark-presence', data: {
      'present': present,
      'reason': reason,
    });
  }
}