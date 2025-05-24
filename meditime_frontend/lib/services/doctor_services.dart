import 'package:dio/dio.dart';
import '../models/doctor_model.dart';
import '../core/constants/api_endpoints.dart';
import '../providers/AuthNotifier.dart'; // ou l'endroit où tu stockes le token
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorService {
  final Dio _dio = Dio();

  Future<List<Doctor>> fetchBestDoctors() async {
    print('Appel API: ${ApiConstants.getAllDoctors}');
    final response = await _dio.get(ApiConstants.getAllDoctors); // adapte l'URL si besoin
    print('Status: ${response.statusCode}, Data: ${response.data}');
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((json) => Doctor.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des médecins');
  }

  // Ajoute ce paramètre si tu utilises Riverpod
  Future<List<Doctor>> fetchDoctorsByProximity(Ref ref) async {
    final token = await ref.read(authProvider.notifier).getToken();
    print('TOKEN UTILISÉ : $token');
    final response = await _dio.get(
      ApiConstants.docProximity,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    print('Status: ${response.statusCode}, Data: ${response.data}');
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((json) => Doctor.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des médecins proches');
  }
}