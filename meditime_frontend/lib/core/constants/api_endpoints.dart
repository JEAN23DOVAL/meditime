import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Classe centralisant tous les endpoints et URLs de l'API.
/// Organisation hiérarchique et professionnelle pour une meilleure lisibilité et évolutivité.
class ApiConstants {
  static String? _baseUrl;
  static bool? _isPhysicalAndroid; // Ajoute cette ligne

  /// Appelle cette méthode au démarrage de l'app (ex: dans main())
  static Future<void> initBaseUrl() async {
    if (kIsWeb) {
      _baseUrl = "http://localhost:3000/api";
      return;
    }
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      _isPhysicalAndroid = androidInfo.isPhysicalDevice ?? false; // Ajoute cette ligne
      if (_isPhysicalAndroid == true) {
        // Téléphone réel Android
        _baseUrl = "http://192.168.213.20:3000/api"; // <-- Mets ici l'IP de ton PC
      } else {
        // Émulateur Android
        _baseUrl = "http://10.0.2.2:3000/api";
      }
      return;
    }
    if (Platform.isIOS) {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.isPhysicalDevice ?? false) {
        _baseUrl = "http://192.168.213.20:3000/api"; // <-- Mets ici l'IP de ton PC
      } else {
        _baseUrl = "http://localhost:3000/api";
      }
      return;
    }
    _baseUrl = "http://192.168.213.20:3000/api";
  }

  static String get baseUrl {
    if (_baseUrl == null) {
      throw Exception("ApiConstants.initBaseUrl() doit être appelée avant d'utiliser baseUrl !");
    }
    return _baseUrl!;
  }

  // =========================
  // === AUTHENTIFICATION ====
  // =========================

  static String get login => "$baseUrl/auth/login";
  static String get register => "$baseUrl/auth/register";
  static String get updateProfile => "$baseUrl/auth/update-profile";
  static String get saveFcmToken => "$baseUrl/auth/fcm-token";

  // =========================
  // === DOCTOR APPLICATION ==
  // =========================

  static String get doctorApplicationSubmit => "$baseUrl/doctor-application/submit";
  static String get doctorApplicationLast => "$baseUrl/doctor-application/last";

  // =========================
  // === ADMIN ===============
  // =========================

  // --- Statistiques & Listes ---
  static String get adminSummaryStats => "$baseUrl/admin/summary-stats";
  static String get adminMedecins => "$baseUrl/admin/medecins";
  static String get adminDoctors => "$baseUrl/admin/doctors";
  static String get adminPatients => "$baseUrl/admin/patients";
  static String get adminPatientsStats => "$baseUrl/admin/patients/stats";
  static String get adminAllMessages => "$baseUrl/messages/all";

  // --- Actions sur Médecins ---
  static String adminMedecinValider(int id) => "$baseUrl/admin/medecins/$id/valider";
  static String adminMedecinRefuser(int id) => "$baseUrl/admin/medecins/$id/refuser";
  static String adminDoctorDetails(int id) => "$baseUrl/admin/doctors/$id";
  static String adminDoctorToggleStatus(int idUser) => "$baseUrl/admin/doctors/$idUser/toggle-status";
  static String adminDoctorDelete(int id) => "$baseUrl/admin/doctors/$id";
  static String adminDoctorResetPassword(int idUser) => "$baseUrl/admin/doctors/$idUser/reset-password";
  static String adminDoctorStats(int idUser) => "$baseUrl/admin/doctors/$idUser/stats";
  static String adminDoctorRdvs(int idUser) => "$baseUrl/admin/doctors/$idUser/rdvs";

  // --- Actions sur Patients ---
  static String adminPatientDetails(int id) => "$baseUrl/admin/patients/$id";
  static String adminPatientToggleStatus(int id) => "$baseUrl/admin/patients/$id/toggle-status";
  static String adminPatientResetPassword(int id) => "$baseUrl/admin/patients/$id/reset-password";
  static String adminPatientSendMessage(int id) => "$baseUrl/admin/patients/$id/message";

  // --- Admin Management ---
  static String get admins => "$baseUrl/admin/admins";

  // =========================
  // === DOCTORS & RDV =======
  // =========================

  // --- Médecins ---
  static String get getAllDoctors => "$baseUrl/doctor/best/all";
  static String get searchDoctors => "$baseUrl/doctor";
  static String get docProximity => "$baseUrl/doctor/proximity";
  static String doctorByUser(int idUser) => "$baseUrl/doctor/user/$idUser";
  static String updateDoctorExtraInfo(int doctorId) => "$baseUrl/doctor/$doctorId/extra";

  // --- RDV & Créneaux ---
  static String get rdv => "$baseUrl/rdv";
  static String get createDoctorSlot => "$baseUrl/rdv/slots";
  static String get getDoctorSlots => "$baseUrl/doctor-slots/doctor";
  static String get getActiveDoctorSlots => "$baseUrl/rdv/slots/active";

  // --- Avis & Consultations ---
  static String doctorReviews(int doctorId) => "$baseUrl/doctor-reviews/doctor/$doctorId";
  static String get consultation => "$baseUrl/consultations";
  static String consultationByRdvId(int rdvId) => "$baseUrl/consultations/rdv/$rdvId";

  // =========================
  // === UPLOADS & FICHIERS ==
  // =========================

  /// Base URL pour les fichiers uploadés (images, PDF, etc.)
  static String get uploadBaseUrl {
    if (kIsWeb) return "http://localhost:3000/uploads";
    if (Platform.isAndroid) {
      // Même logique que pour _baseUrl
      final deviceInfo = DeviceInfoPlugin();
      // ATTENTION : DeviceInfoPlugin().androidInfo est async, donc il faut stocker le résultat au démarrage
      // Pour rester synchrone ici, on va utiliser une variable statique initialisée dans initBaseUrl()
      if (_isPhysicalAndroid == true) {
        return "http://192.168.213.20:3000/uploads"; // <-- Mets ici l'IP de ton PC
      }
      return "http://10.0.2.2:3000/uploads";
    }
    if (Platform.isIOS) return "http://localhost:3000/uploads";
    return "http://192.168.213.20:3000/uploads";
  }

  /// Génère une URL d'upload pour un chemin donné.
  static String getUploadUrl(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "$uploadBaseUrl/$cleanPath";
  }

  /// Génère une URL complète pour un fichier uploadé (photo, PDF, etc.)
  static String getFileUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/uploads')) {
      return "${uploadBaseUrl}${path.substring('/uploads'.length)}";
    }
    // Pour les anciens chemins relatifs ou juste le nom du fichier
    return "$uploadBaseUrl/$path";
  }

  // =========================
  // === HEADERS & TIMEOUT ===
  // =========================

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const int connectionTimeout = 5000;
  static const int receiveTimeout = 3000;
}