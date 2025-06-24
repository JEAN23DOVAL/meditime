import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import 'package:meditime_frontend/core/network/dio_client.dart';
import 'package:meditime_frontend/models/rdv_model.dart';
import '../models/medecin.dart';

class MedecinService {
  final _dio = DioClient().dio;

  // Récupère toutes les demandes de doctor_applications (pending, accepted, refused)
  Future<List<Medecin>> fetchAllMedecins() async {
    final response = await _dio.get(ApiConstants.adminMedecins);
    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List)
          .map((e) => Medecin.fromJson(e))
          .toList();
    }
    throw Exception('Erreur lors de la récupération des demandes');
  }

  // Valider une demande
  Future<void> validerMedecin(int id) async {
    await _dio.patch(ApiConstants.adminMedecinValider(id));
  }

  // Refuser une demande
  Future<void> refuserMedecin(int id, String message) async {
    await _dio.patch(ApiConstants.adminMedecinRefuser(id), data: {'admin_message': message});
  }

  // Suspendre/réactiver un médecin validé
  Future<void> suspendreMedecin(int idUser) async {
    await _dio.patch(ApiConstants.adminDoctorToggleStatus(idUser));
  }

  // Supprimer un médecin validé
  Future<void> supprimerMedecin(int id) async {
    await _dio.delete(ApiConstants.adminDoctorDelete(id));
  }

  // Réinitialiser le mot de passe d'un médecin validé
  Future<String> resetMedecinPassword(int idUser) async {
    final response = await _dio.post(ApiConstants.adminDoctorResetPassword(idUser));
    return response.data['tempPassword'] ?? 'N/A';
  }

  // Récupérer les stats d'un médecin validé
  Future<Map<String, dynamic>> getDoctorStats(int idUser) async {
    final response = await _dio.get(ApiConstants.adminDoctorStats(idUser));
    return response.data;
  }

  // Récupérer les rdvs d’un médecin (admin)
  Future<List<Rdv>> fetchDoctorRdvs(int idUser) async {
    final response = await _dio.get(ApiConstants.adminDoctorRdvs(idUser));
    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List).map((e) {
        // On adapte le champ patient selon le backend (rdvPatient)
        final map = Map<String, dynamic>.from(e);
        if (map['rdvPatient'] != null) {
          map['patient'] = map['rdvPatient'];
        }
        return Rdv.fromJson(map);
      }).toList();
    }
    throw Exception('Erreur lors de la récupération des rendez-vous');
  }
}