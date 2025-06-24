import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meditime_frontend/models/user_model.dart';
import 'package:meditime_frontend/services/local_storage_service.dart';
import 'package:meditime_frontend/core/network/socket_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final token = await LocalStorageService.getToken();
      if (token != null) {
        final payload = JwtDecoder.decode(token);
        state = User.fromMap(payload);
      }
    } catch (e) {
      state = null;
    }
  }

  Future<void> saveToken(String token) async {
    await LocalStorageService.saveToken(token);
    try {
      final payload = JwtDecoder.decode(token);
      state = User.fromMap(payload);
      // Connecte le socket après login
      final container = ProviderContainer();
      await container.read(socketServiceProvider).connect();
    } catch (e) {
      state = null;
    }
  }

  Future<void> reloadFromToken(String token) async {
    try {
      final payload = JwtDecoder.decode(token);
      state = User.fromMap(payload);
    } catch (e) {
      state = null;
    }
  }

  Future<void> logout() async {
    await LocalStorageService.deleteToken();
    state = null;
  }

  Future<String?> getToken() async {
    final token = await LocalStorageService.getToken();
    return token;
  }

  void updateUser(User user) {
    state = user;
  }
}