import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meditime_frontend/core/network/dio_client.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import 'package:meditime_frontend/features/home/user/rdv/widgets/rdv_list.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/models/user_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';
import 'package:meditime_frontend/services/local_storage_service.dart';
import 'package:meditime_frontend/services/notification_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  AuthService(this.ref);

  final Ref ref;

  final Dio _dio = DioClient().dio;

  Future<User?> login(String email, String motDePasse) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': motDePasse},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final token = response.data['token'];
        if (token != null) {
          await LocalStorageService.saveToken(token);
          await ref.read(authProvider.notifier).reloadFromToken(token);
          final payload = JwtDecoder.decode(token);
          final user = User.fromMap(payload);
          ref.read(authProvider.notifier).updateUser(user);

          // Invalide les providers RDV pour rafraîchir la home
          ref.invalidate(nextPatientRdvProvider);
          ref.invalidate(nextDoctorRdvProvider);

          // Si tu utilises rdvListProvider quelque part avec des params :
          ref.invalidate(rdvListProvider(RdvListParams(patientId: user.idUser)));
          if (user.doctorId != null) {
            ref.invalidate(rdvListProvider(RdvListParams(doctorId: user.doctorId)));
          }

          final fcmToken = await NotificationService.getFcmToken();
          if (fcmToken != null) {
            // Appelle ton endpoint backend pour enregistrer le token FCM
            await _dio.post(ApiConstants.saveFcmToken, data: {'token': fcmToken});
          }
          return user;
        }
      }
    } catch (e) {
      print("❌ Erreur login: $e");
    }
    return null;
  }

  Future<User?> register({
    required String nom,
    required String email,
    required String motDePasse,
    PlatformFile? photoProfilFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'lastName': nom,
        'email': email,
        'password': motDePasse,
        if (photoProfilFile != null && photoProfilFile.path != null)
          'photo_profil': await MultipartFile.fromFile(
            photoProfilFile.path!,
            filename: photoProfilFile.name,
          ),
      });

      final registerResponse = await _dio.post(ApiConstants.register, data: formData);

      if (registerResponse.statusCode == 201) {
        // Récupère l'utilisateur après inscription
        final user = await login(email, motDePasse);

        // Envoie le token FCM au backend
        final fcmToken = await NotificationService.getFcmToken();
        if (fcmToken != null) {
          await _dio.post(ApiConstants.saveFcmToken, data: {'token': fcmToken});
        }

        return user;
      }
    } catch (e) {
      print("❌ Erreur inscription: $e");
    }
    return null;
  }
}