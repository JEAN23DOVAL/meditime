import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/services/local_storage_service.dart';

class FirstLaunchNotifier extends AsyncNotifier<bool> {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  @override
  Future<bool> build() async {
    return await LocalStorageService.isFirstLaunch();
  }

  Future<void> complete() async {
    await LocalStorageService.completeFirstLaunch();
    state = const AsyncValue.data(false);
    _controller.add(null); // Notifie le changement
  }

  void onDispose() {
    _controller.close(); // Ne pas oublier de fermer le stream
  }
}

final firstLaunchProvider = AsyncNotifierProvider<FirstLaunchNotifier, bool>(
  () => FirstLaunchNotifier(),
);