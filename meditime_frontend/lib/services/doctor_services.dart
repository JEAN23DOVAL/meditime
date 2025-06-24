import 'package:dio/dio.dart';
import '../models/doctor_model.dart';
import '../core/constants/api_endpoints.dart';
import '../providers/AuthNotifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart'; // <-- Ajoute cet import

class DoctorService {
  final Dio _dio = DioClient().dio; // <-- Correction ici

  Future<List<Doctor>> fetchBestDoctors() async {
    final response = await _dio.get(ApiConstants.getAllDoctors); // adapte l'URL si besoin
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((json) => Doctor.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des médecins');
  }

  // Ajoute ce paramètre si tu utilises Riverpod
  Future<List<Doctor>> fetchDoctorsByProximity(Ref ref) async {
    final token = await ref.read(authProvider.notifier).getToken();
    final response = await _dio.get(
      ApiConstants.docProximity,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((json) => Doctor.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des médecins proches');
  }

  Future<Doctor> fetchDoctorByIdUser(int idUser) async {
    final response = await _dio.get(ApiConstants.doctorByUser(idUser));
    if (response.statusCode == 200) {
      return Doctor.fromJson(response.data);
    }
    throw Exception('Erreur lors de la récupération du médecin');
  }

  // Nouvelle méthode pour mettre à jour les informations supplémentaires du médecin
  Future<void> updateDoctorExtraInfo({
    required int doctorId,
    required int experienceYears,
    required int pricePerHour,
    required String description,
    required WidgetRef ref, // <-- ici !
  }) async {
    final token = await ref.read(authProvider.notifier).getToken();
    final response = await _dio.patch(
      ApiConstants.updateDoctorExtraInfo(doctorId),
      data: {
        'experienceYears': experienceYears,
        'pricePerHour': pricePerHour,
        'description': description,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          ...ApiConstants.defaultHeaders,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour des informations du médecin');
    }
  }

  // Ajoute cette méthode dans DoctorService
  Future<List<Doctor>> fetchDoctorsByProximityWithCity(Ref ref, String? city) async {
    final token = await ref.read(authProvider.notifier).getToken();
    final response = await _dio.get(
      ApiConstants.docProximity,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          ...ApiConstants.defaultHeaders,
        },
      ),
    );
    if (response.statusCode == 200) {
      final data = response.data as List;
      final doctors = data.map((json) => Doctor.fromJson(json)).toList();
      if (city != null && city.isNotEmpty) {
        // Trie par ville du patient d'abord, puis les autres
        return [
          ...doctors.where((d) => d.user?.city == city),
          ...doctors.where((d) => d.user?.city != city),
        ];
      }
      return doctors;
    }
    throw Exception('Erreur lors de la récupération des médecins proches');
  }

  Future<List<Doctor>> searchDoctors({
    String? search,
    bool? available,
    double? minPrice,
    double? maxPrice,
    String? gender,
  }) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (available != null) params['available'] = available;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (gender != null && gender.isNotEmpty) params['gender'] = gender;

    final response = await _dio.get(
      "${ApiConstants.baseUrl}/doctor", // <-- Utilise bien /doctor
      queryParameters: params,
    );
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((json) => Doctor.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la recherche des médecins');
  }
}