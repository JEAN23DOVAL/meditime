import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_assets.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/widgets/buttons/buttons.dart';
import 'package:meditime_frontend/configs/app_routes.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Message de bienvenue
              Text(
                'Bienvenue sur MediTime !',
                style: AppStyles.heading1.copyWith(color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              /// Illustration
              Image.asset(
                AppAssets.welcomeIllustration,
                height: 250,
                semanticLabel: 'Illustration de bienvenue',
              ),
              const SizedBox(height: 32),

              /// Bouton Connexion
              LoginButton(
                onPressed: () {
                  context.go(AppRoutes.connexion);
                },
                label: 'Se connecter',
                icon: Icons.login,
              ),
              const SizedBox(height: 16),

              /// Bouton Inscription
              RegisterButton(
                onPressed: () {
                  context.go(AppRoutes.inscription);
                },
                label: 'Créer un compte',
                icon: Icons.edit,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}