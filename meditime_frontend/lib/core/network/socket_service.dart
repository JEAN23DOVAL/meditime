import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import 'package:meditime_frontend/services/local_storage_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

class SocketService {
  IO.Socket? _socket;

  // Appelle cette méthode pour connecter le socket avec le token courant
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;
    final token = await LocalStorageService.getToken();
    _socket = IO.io(
      ApiConstants.baseUrl.replaceFirst('/api', ''),
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setQuery({'token': token})
        .build(),
    );
    _socket!.onConnect((_) => print('[SOCKET] Connected'));
    _socket!.onDisconnect((_) => print('[SOCKET] Disconnected'));
    _socket!.onError((err) => print('[SOCKET] Error: $err'));
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
  }
}