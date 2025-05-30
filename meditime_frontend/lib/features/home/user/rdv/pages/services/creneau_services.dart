import 'package:dio/dio.dart';
import 'package:meditime_frontend/core/network/dio_client.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import '../models/doctor_slot_model.dart';
import '../models/available_slot_model.dart'; // Ajoute l'import

class TimeslotService {
  final _dio = DioClient().dio;

  // Créer un créneau
  Future<DoctorSlot?> createSlot(DoctorSlot slot) async {
    try {
      final response = await _dio.post(
        ApiConstants.createDoctorSlot,
        data: slot.toJson(),
      );

      if (response.statusCode == 201) {
        return DoctorSlot.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw 'Ce créneau existe déjà';
      } else if (e.response?.statusCode == 404) {
        throw 'Médecin introuvable';
      }
      throw 'Erreur lors de la création du créneau';
    }
  }

  // Récupérer les créneaux actifs d'un médecin
  Future<List<DoctorSlot>> getActiveSlotsByDoctor(int doctorId) async {
    try {
      final response = await _dio.get('${ApiConstants.getActiveDoctorSlots}/$doctorId');
      if (response.statusCode == 200) {
        final slots = (response.data as List)
            .map((json) => DoctorSlot.fromJson(json))
            .toList();
        return slots;
      }
      return [];
    } catch (e) {
      throw 'Erreur lors de la récupération des créneaux actifs';
    }
  }

  // Modifier un créneau
  Future<DoctorSlot?> updateSlot(DoctorSlot slot) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.createDoctorSlot}/${slot.id}', // PUT /rdv/slots/:id
        data: slot.toJson(),
      );
      if (response.statusCode == 200) {
        return DoctorSlot.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw 'Erreur lors de la modification du créneau';
    }
  }

  // Supprimer un créneau
  Future<void> deleteSlot(int slotId) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.createDoctorSlot}/$slotId', // DELETE /rdv/slots/:id
      );
      if (response.statusCode != 200) {
        throw 'Erreur lors de la suppression du créneau';
      }
    } catch (e) {
      throw 'Erreur lors de la suppression du créneau';
    }
  }

  Future<List<AvailableSlot>> getAvailableSlots({
    required int doctorId,
    required String date,
    required String token,
  }) async {
    final response = await _dio.get(
      ApiConstants.rdv + '/available-slots',
      queryParameters: {
        'doctor_id': doctorId,
        'date': date,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final slots = data['available'] as List;
      final now = DateTime.now();

      // Filtre ici : ne garde que les créneaux dont le début est dans le futur
      return slots
          .map((json) => AvailableSlot.fromJson(json))
          .where((slot) => slot.start.isAfter(now))
          .toList();
    }
    throw Exception('Erreur lors de la récupération des créneaux disponibles');
  }
}