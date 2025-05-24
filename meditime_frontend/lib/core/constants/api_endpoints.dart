/// Fichier de configuration des points d’accès API pour l’authentification.
///
/// Contient :
/// - L’URL de base de l’API
/// - Les endpoints liés à l’auth (connexion, inscription)
/// - Les en-têtes HTTP standard
/// - Les délais de timeout

class ApiConstants {
  // 📍 Base URL pour l’environnement local Android Emulator
  static const String baseUrl = "http://10.0.2.2:3000/api"; // <-- avec /api si tu utilises ce préfixe

  // 🔐 Auth Endpoints
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String updateProfile = "$baseUrl/auth/update-profile";

  // 🩺 Doctor Application Endpoints (corrigé)
  static const String doctorApplicationSubmit = "$baseUrl/doctor-application/submit";
  static const String doctorApplicationLast = "$baseUrl/doctor-application/last"; // à compléter avec /:idUser

  // 📊 Admin Endpoints
  static const String adminSummaryStats = "$baseUrl/admin/summary-stats";
  static const String adminMedecins = "$baseUrl/admin/medecins";

  // 📬 Messages Endpoints
  static const String adminAllMessages = "$baseUrl/messages/all";

  // 👨‍⚕️📅 Doctor Slots Endpoints
  static const String createDoctorSlot = "$baseUrl/rdv/slots";
  static const String getDoctorSlots = "$baseUrl/doctor-slots/doctor";
  static const String getActiveDoctorSlots = "$baseUrl/rdv/slots/active";
  static const String getAllDoctors = "$baseUrl/doctor/best/all";
  static const String docProximity = "$baseUrl/doctor/proximity"; // Endpoint pour récupérer les médecins proches

  // 📦 Headers communs aux requêtes HTTP
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ⏱ Timeout en millisecondes
  static const int connectionTimeout = 5000; // 5 secondes
  static const int receiveTimeout = 3000;    // 3 secondes
}