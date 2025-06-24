import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/core/network/socket_service.dart';

mixin SocketListenerMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late final SocketService socketService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketService = ref.read(socketServiceProvider);
  }

  void listenSocket(String event, Function(dynamic) handler) {
    socketService.on(event, handler);
  }

  void stopListening(String event) {
    socketService.off(event);
  }
}