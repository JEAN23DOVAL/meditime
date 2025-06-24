class AppRoutes {
  static const splash = '/splash';
  static const onboarding1 = '/onboarding-1';
  static const onboarding2 = '/onboarding-2';
  static const onboarding3 = '/onboarding-3';
  static const welcome = '/welcome';
  static const connexion = '/connexion';
  static const inscription = '/inscription';
  static const forgotPass = '/forgot_password_screen';
  static const homeUser = '/home_user';
  static const comfirmAccount = '/confirmer_compte';
  static const devenirMedecin = '/devenir_medecin_screen';

  // Admin Routes
  static const adminDashboard = '/admin_dashboard_screen';
  static const medecinList = '/medecin_list_screen';
  static const String adminMessages = '/admin_messages_page';
  static const patientScreen = '/patient_admin_screen';
  static const adminManagement = '/admin_management_screen';
  static const adminRdv = '/admin/rdvs';
  static const adminStats = '/admin_stats_screen';

  // Rendez-vous Routes
  static const rendezVous = '/rdv_form_page';
  static const creneaudoctor = '/doctor_timeslots_pages';
  static const doctorDetail = '/doctor_details';
  static const rdvPage = '/rdv_page';
  static const consultationDetails = '/consultation/:rdvId';  // avec paramètre rdvId

  // Profil Routes
  static const editProfile = '/edit_profile_page';
  static const security = '/security_page';
  static const notifications = '/notifications_page';
  static const addRelative = '/add_relative_page';
  static const healthRecord = '/health_record_page';
  static const reviews = '/reviews_page';
  static const help = '/help_page';
  static const language = '/language_page';
  static const patientsList = '/patients_list_page';
  static const stats = '/stats_page';
  static const favorites = '/favorites_page';
  static const settings = '/setting_page';
  static const documents = '/documents_page';
}