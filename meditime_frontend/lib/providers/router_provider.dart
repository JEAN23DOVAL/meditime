import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/features/RDV/pages/rdv_form_page.dart';
import 'package:meditime_frontend/features/home/admin/admin_dashboard_screen.dart';
import 'package:meditime_frontend/features/home/admin/medecin/medecin_list_screen.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/confirmer_compte.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/devenir_medecin/devenir_medecin_screen.dart';
import 'package:meditime_frontend/features/home/user/home_users.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/doctor_timeslots_pages.dart';

import 'package:meditime_frontend/features/splash/splash_screen.dart';
import 'package:meditime_frontend/features/onboarding/onboarding_1_screen.dart';
import 'package:meditime_frontend/features/onboarding/onboarding_2_screen.dart';
import 'package:meditime_frontend/features/onboarding/onboarding_3_screen.dart';
import 'package:meditime_frontend/features/onboarding/welcome_screen.dart';
import 'package:meditime_frontend/features/auth/connexion_screen.dart';
import 'package:meditime_frontend/features/auth/forgot_password_screen.dart';
import 'package:meditime_frontend/features/auth/inscription_1_screen.dart';
import 'package:meditime_frontend/providers/first_launch_provider.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/widgets/utils/go_router_refresh_stream.dart';
import 'package:meditime_frontend/widgets/transition/fade_transition_page.dart';
import 'package:meditime_frontend/features/home/admin/messages/admin_messages_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final firstLaunchAsync = ref.watch(firstLaunchProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(firstLaunchProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final currentPath = state.uri.path;

      // 1) Si on attend encore la résolution
      if (firstLaunchAsync.isLoading || firstLaunchAsync.hasError) {
        return null; // SplashScreen se chargera
      }

      final isFirstLaunch = firstLaunchAsync.value ?? true;

      if (isFirstLaunch) {
        // Redirige tout sauf splash vers splash
        const allowedDuringFirstLaunch = [
          AppRoutes.splash,
          AppRoutes.onboarding1,
          AppRoutes.onboarding2,
          AppRoutes.onboarding3,
          AppRoutes.welcome,
        ];
        if (!allowedDuringFirstLaunch.contains(currentPath)) {
          return AppRoutes.splash;
        }
      } else {
        // Si déjà vu, bloque l'accès aux écrans d'accueil/init
        const blockedPaths = [
          // AppRoutes.splash,
          AppRoutes.onboarding1,
          AppRoutes.onboarding2,
          AppRoutes.onboarding3,
          AppRoutes.welcome,
        ];
        if (blockedPaths.contains(currentPath)) {
          return AppRoutes.connexion;
        }
      }

      return null; // Pas de redirection
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const SplashScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding1,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const Onboarding1Screen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding2,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const Onboarding2Screen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding3,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const Onboarding3Screen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const WelcomeScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.connexion,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const ConnexionScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.inscription,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const SignupScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPass,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const ForgotPasswordScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.homeUser,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const HomeUsers(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.comfirmAccount,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const ConfirmerCompte(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.devenirMedecin,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const DevenirMedecinScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const AdminDashboardScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.medecinList,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const MedecinListScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminMessages,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const AdminMessagesPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.rendezVous,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const RdvFormPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.creneaudoctor,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const DoctorTimeslotsPage(),
          key: state.pageKey,
        ),
      ),
    ],
  );
});