import 'package:dio/dio.dart';
import 'package:meditime_frontend/core/network/dio_client.dart';
import 'package:meditime_frontend/models/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';

class UserService {
  final DioClient _dio = DioClient();

  Future<Map<String, dynamic>?> updateProfile({
    required String lastName,
    required String firstName,
    required String email,
    required String city,
    required String phone,
    required String gender,
    required String birthDate,
    PlatformFile? profilePhoto,
  }) async {
    try {
      final formData = FormData();

      formData.fields
        ..add(MapEntry('lastName', lastName))
        ..add(MapEntry('firstName', firstName))
        ..add(MapEntry('email', email))
        ..add(MapEntry('city', city))
        ..add(MapEntry('phone', phone))
        ..add(MapEntry('gender', gender))
        ..add(MapEntry('birthDate', birthDate));

      if (profilePhoto != null) {
        formData.files.add(MapEntry(
          'profilePhoto',
          MultipartFile.fromBytes(profilePhoto.bytes!, filename: profilePhoto.name),
        ));
      }

      final response = await _dio.post(ApiConstants.updateProfile, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'user': User.fromMap(response.data['user'] ?? response.data),
          'token': response.data['token'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      rethrow;
    }
  }
}