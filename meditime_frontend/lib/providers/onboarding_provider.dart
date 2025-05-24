// lib/features/onboarding/provider/onboarding_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/providers/router_provider.dart';
import 'package:meditime_frontend/configs/app_routes.dart';

// Définition des différentes étapes de l'onboarding
enum OnboardingStep { step1, step2, step3, done }

// StateNotifier qui gère l'état courant de l'onboarding
class OnboardingNotifier extends StateNotifier<OnboardingStep> {
  final Ref ref;

  OnboardingNotifier(this.ref) : super(OnboardingStep.step1);

  /// Passe à l'étape suivante
  void next() {
    switch (state) {
      case OnboardingStep.step1:
        _goToStep(OnboardingStep.step2, AppRoutes.onboarding2);
        break;
      case OnboardingStep.step2:
        _goToStep(OnboardingStep.step3, AppRoutes.onboarding3);
        break;
      case OnboardingStep.step3:
        _goToStep(OnboardingStep.done, AppRoutes.welcome);
        break;
      case OnboardingStep.done:
        ref.read(routerProvider).go(AppRoutes.welcome);
        break;
    }
  }

  /// Passe directement à la fin de l'onboarding
  void skip() {
    _goToStep(OnboardingStep.done, AppRoutes.welcome);
  }

  /// Revient à l'étape précédente
  void previous() {
    switch (state) {
      case OnboardingStep.step2:
        _goToStep(OnboardingStep.step1, AppRoutes.onboarding1);
        break;
      case OnboardingStep.step3:
        _goToStep(OnboardingStep.step2, AppRoutes.onboarding2);
        break;
      case OnboardingStep.step1:
      case OnboardingStep.done:
        break;
    }
  }

  /// Méthode privée pour changer d'étape et naviguer
  void _goToStep(OnboardingStep step, String route) {
    state = step;
    ref.read(routerProvider).go(route);
  }
}

// Provider global pour accéder à l'état de l'onboarding
final onboardingStepProvider = StateNotifierProvider<OnboardingNotifier, OnboardingStep>(
  (ref) => OnboardingNotifier(ref),
);