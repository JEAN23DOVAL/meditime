import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/services/local_storage_service.dart';

Future<void> handleLogout(WidgetRef ref, GoRouter router) async {
  // 1. Supprimer le token local
  await LocalStorageService.deleteToken(); // <-- Correction ici
  // 2. Réinitialiser l'état utilisateur (si tu utilises un provider)
  ref.read(authProvider.notifier).logout();
  // 3. Rediriger vers la page de connexion
  router.go(AppRoutes.connexion);
}