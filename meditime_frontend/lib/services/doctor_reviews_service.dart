import 'package:dio/dio.dart';
import 'package:meditime_frontend/models/doctor_reviews_model.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/dio_client.dart';

class DoctorReviewService {
  final Dio _dio = DioClient().dio;

  Future<DoctorReview> createReview({
    required int doctorId,
    required int rating,
    required String comment,
    required String token,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.baseUrl}/doctor-reviews',
      data: {
        'doctor_id': doctorId,
        'rating': rating,
        'comment': comment,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          ...ApiConstants.defaultHeaders,
        },
      ),
    );
    if (response.statusCode == 201) {
      return DoctorReview.fromJson(response.data);
    }
    throw Exception(response.data['message'] ?? 'Erreur lors de l\'envoi de l\'avis');
  }

  Future<List<DoctorReview>> fetchReviewsByDoctor(int doctorId) async {
    final response = await _dio.get(
      ApiConstants.doctorReviews(doctorId),
      options: Options(headers: ApiConstants.defaultHeaders),
    );
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((json) => DoctorReview.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des avis');
  }
}