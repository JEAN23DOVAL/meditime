import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const _tokenKey = 'jwt_token';
  static const _firstLaunchKey = 'first_launch_done';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Ajoute ces méthodes pour la gestion du premier lancement
  static Future<bool> isFirstLaunch() async {
    final value = await _storage.read(key: _firstLaunchKey);
    return value != 'true';
  }

  static Future<void> completeFirstLaunch() async {
    await _storage.write(key: _firstLaunchKey, value: 'true');
  }
}