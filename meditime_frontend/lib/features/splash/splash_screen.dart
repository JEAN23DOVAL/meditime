import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:meditime_frontend/configs/app_assets.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/services/local_storage_service.dart';
import 'package:meditime_frontend/configs/app_routes.dart';

/// SplashScreen :  
/// - Affiche le logo + animation Lottie  
/// - Attend la fin de l’animation et le chargement des flags  
/// - Puis redirige vers Onboarding ou Login selon l’état
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _heartOpacity;

  @override
  void initState() {
    super.initState();

    // 1. Prépare l’AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // 2. Définis deux intervalles d’opacité pour le logo et le cœur
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );
    _heartOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );

    // 3. Démarre les animations
    _controller.forward();

    // 4. Lance le timer de navigation après la durée totale
    _startNavigationTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Délai égal à la durée de l’animation, puis navigation conditionnelle
  void _startNavigationTimer() {
    Timer(_controller.duration!, () async {
      final firstLaunch = await LocalStorageService.isFirstLaunch();
      if (firstLaunch) {
        await LocalStorageService.completeFirstLaunch();
        context.go(AppRoutes.onboarding1);
      } else {
        context.go(AppRoutes.connexion);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Utilise la couleur de fond définie dans AppColors
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo en fondu
            FadeTransition(
              opacity: _logoOpacity,
              child: Image.asset(
                AppAssets.logo,
                width: 180,
                height: 180,
              ),
            ),

            const SizedBox(height: 24),

            // Animation cœur en Lottie, en fondu
            FadeTransition(
              opacity: _heartOpacity,
              child: Lottie.asset(
                AppAssets.heartLoading,
                width: 150,
                height: 150,
                repeat: true,
              ),
            ),

            const SizedBox(height: 24),

            // Barre de progression
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: LinearProgressIndicator(
                // Couleur principale pour le progress bar
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primary),
                backgroundColor: AppColors.secondary.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}