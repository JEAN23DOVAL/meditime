import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/features/RDV/pages/rdv_form_page.dart';
import 'package:meditime_frontend/features/home/admin/admin_dashboard_screen.dart';
import 'package:meditime_frontend/features/home/admin/medecin/medecin_list_screen.dart';
import 'package:meditime_frontend/features/home/admin/patients/patient_admin_screen.dart';
import 'package:meditime_frontend/features/home/admin/stats/admin_stats_screen.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/confirmer_compte.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/devenir_medecin/devenir_medecin_screen.dart';
import 'package:meditime_frontend/features/home/user/consultation/consultation_page.dart';
import 'package:meditime_frontend/features/home/user/doctors/doctors_page.dart';
import 'package:meditime_frontend/features/home/user/doctors/pages/doctor_details.dart';
import 'package:meditime_frontend/features/home/user/home_users.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/add_relative_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/edit_profile_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/health_record_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/notifications_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/patients_list_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/security_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/setting_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/stats_page.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/doctor_timeslots_pages.dart';
import 'package:meditime_frontend/features/home/user/rdv/rdv_page.dart';
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
import 'package:meditime_frontend/widgets/payment_webview.dart';
import 'package:meditime_frontend/widgets/utils/go_router_refresh_stream.dart';
import 'package:meditime_frontend/widgets/transition/fade_transition_page.dart';
import 'package:meditime_frontend/features/home/admin/messages/admin_messages_page.dart';
import 'package:meditime_frontend/features/home/admin/admin_management/admin_management_screen.dart';
import 'package:meditime_frontend/features/home/admin/rdv/admin_rdv_list_screen.dart';
import 'package:meditime_frontend/features/home/admin/rdv/admin_rdv_detail_screen.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/help_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/language_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/reviews_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/favorites_page.dart';
import 'package:meditime_frontend/features/home/user/profile/pages/documents_page.dart';

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
          AppRoutes.connexion,      // Ajoute ceci
          AppRoutes.inscription,    // Et ceci
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
        path: AppRoutes.patientScreen,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const PatientAdminScreen(),
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
        path: AppRoutes.adminManagement,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const AdminManagementScreen(),
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
      // ROUTE DETAIL MEDECIN AVEC PARAMETRE
      GoRoute(
        path: '${AppRoutes.doctorDetail}/:idUser',
        pageBuilder: (context, state) {
          final idUser = int.parse(state.pathParameters['idUser']!);
          return buildFadeTransitionPage(
            child: DoctorDetailPages(idUser: idUser),
            key: state.pageKey,
        );
        },
      ),
      GoRoute(
        path: AppRoutes.rdvPage,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: RdvPage(), // ou détecte le rôle si besoin
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/doctors/nearby',
        builder: (context, state) => const DoctorPage(),
      ),
      // Ajoute cette nouvelle route
      GoRoute(
        path: AppRoutes.consultationDetails,
        pageBuilder: (context, state) {
          final rdvId = int.parse(state.pathParameters['rdvId']!);
          return buildFadeTransitionPage(
            child: ConsultationDetailsPage(
              rdvId: rdvId,
              canEdit: state.extra != null ? (state.extra as Map)['canEdit'] ?? false : false,
            ),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminRdv,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const AdminRdvListScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.adminRdv}/:id',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return buildFadeTransitionPage(
            child: AdminRdvDetailScreen(rdvId: id),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminStats,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const AdminStatsScreen(),
          key: state.pageKey,
        ),
      ),
      
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const EditProfilePage(),
          key: state.pageKey,
        ),
      ),
      
      GoRoute(
        path: AppRoutes.security,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const SecurityPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const NotificationsPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.addRelative,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const AddRelativePage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.healthRecord,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const HealthRecordPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.reviews,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const ReviewsPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.help,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const HelpPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.language,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const LanguagePage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.patientsList,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const PatientsListPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.stats,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const StatsPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const FavoritesPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const SettingPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: AppRoutes.documents,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          child: const DocumentsPage(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/payment_webview',
        pageBuilder: (context, state) {
          final url = (state.extra as Map)['url'] as String;
          final transactionId = (state.extra as Map)['transactionId'] as String;
          return buildFadeTransitionPage(
            child: PaymentWebView(
              url: url,
              transactionId: transactionId,
            ),
            key: state.pageKey,
          );
        },
      ),
    ],
  );
});