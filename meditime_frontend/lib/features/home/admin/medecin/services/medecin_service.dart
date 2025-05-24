import 'package:meditime_frontend/core/network/dio_client.dart';
import '../models/medecin.dart';

class MedecinService {
  final _dio = DioClient().dio;

  /// Récupère toutes les demandes de doctor_applications
  Future<List<Medecin>> fetchAllMedecins() async {
    final response = await _dio.get('/admin/medecins');
    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List)
          .map((e) => Medecin.fromJson(e))
          .toList();
    }
    throw Exception('Erreur lors de la récupération des demandes');
  }

  Future<void> validerMedecin(int doctorApplicationId) async {
    await _dio.patch('/admin/medecins/$doctorApplicationId/valider');
  }

  Future<void> refuserMedecin(int doctorApplicationId, String message) async {
    await _dio.patch('/admin/medecins/$doctorApplicationId/refuser', data: {
      'admin_message': message,
    });
  }
}