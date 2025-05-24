import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meditime_frontend/core/network/dio_client.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/models/user_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meditime_frontend/services/local_storage_service.dart';

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
          await LocalStorageService.saveToken(token); // Sauvegarde le token
          final testToken = await LocalStorageService.getToken();
          print('Token lu juste après sauvegarde : $testToken');
          await ref.read(authProvider.notifier).reloadFromToken(token); // Met à jour l'utilisateur
          // Décoder le token pour récupérer les infos utilisateur
          final payload = JwtDecoder.decode(token);
          final user = User.fromMap(payload);
          ref.read(authProvider.notifier).updateUser(user);
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
        return await login(email, motDePasse);
      }
    } catch (e) {
      print("❌ Erreur inscription: $e");
    }
    return null;
  }
}
