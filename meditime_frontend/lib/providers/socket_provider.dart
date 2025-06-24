import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/core/network/socket_service.dart';
import 'package:meditime_frontend/features/home/admin/provider/admin_stats_provider.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';
import 'package:meditime_frontend/features/home/user/providers/user_message_provider.dart';
import 'package:meditime_frontend/services/notification_service.dart';
import 'package:meditime_frontend/providers/doctor_provider.dart';
import 'package:meditime_frontend/services/consultation_service.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/provider/creneau_provider.dart';
import 'package:meditime_frontend/providers/patient_providers.dart';
import 'package:meditime_frontend/features/home/admin/stats/stats_params.dart'; // en haut du fichier

final socketGlobalListenerProvider = Provider<void>((ref) {
  final socketService = ref.read(socketServiceProvider);

  // RDV temps réel
  socketService.on('rdv_update', (data) {
    print('[SOCKET] rdv_update reçu: $data');
    ref.invalidate(rdvListProvider);
    ref.invalidate(nextPatientRdvProvider);
    ref.invalidate(nextDoctorRdvProvider);
  });

  // Messages utilisateur
  socketService.on('new_message', (data) {
    print('[SOCKET] new_message reçu: $data');
    ref.invalidate(userMessagesProvider('all'));
    ref.invalidate(userMessagesProvider('doctor'));
    ref.invalidate(userMessagesProvider('admin'));
    NotificationService.showMessageNotification(data);
  });
  socketService.on('message_sent', (data) {
    ref.invalidate(userMessagesProvider('all'));
    ref.invalidate(userMessagesProvider('doctor'));
    ref.invalidate(userMessagesProvider('admin'));
  });

  // Consultation temps réel
  socketService.on('consultation_update', (data) {
    if (data is Map && data['consultation']?['rdv_id'] != null) {
      ref.invalidate(consultationByRdvProvider(data['consultation']['rdv_id']));
    }
  });

  // Profil utilisateur (après updateProfile)
  socketService.on('profile_update', (data) {
    ref.invalidate(authProvider);
  });

  // Doctor application temps réel (pour admin)
  socketService.on('doctor_application_update', (data) {
    // Ajoute ici l'invalidation de ton provider de demandes si tu en as
    // ref.invalidate(doctorApplicationsProvider);
  });

  // Validation/refus médecin (pour l'utilisateur concerné)
  socketService.on('doctor_validation', (data) {
    ref.invalidate(authProvider);
    // Tu peux afficher une notification locale ici si besoin
  });

  // Avis médecin temps réel
  socketService.on('review_update', (data) {
    if (data is Map && data['review']?['doctor_id'] != null) {
      ref.invalidate(doctorReviewsProvider(data['review']['doctor_id']));
    }
  });

  // Créneaux médecin (slots)
  socketService.on('slot_update', (data) {
    if (data is Map && data['slot']?['doctorId'] != null) {
      ref.invalidate(activeDoctorTimeslotsProvider(data['slot']['doctorId']));
    }
  });

  // Patient update (suspension, réactivation, etc.)
  socketService.on('patient_update', (data) {
    if (data is Map && data['patient']?['idUser'] != null) {
      ref.invalidate(patientDetailProvider(data['patient']['idUser']));
      ref.invalidate(patientListProvider({})); // Invalide la liste globale
    }
  });

  // Actions admin (ex: suspension)
  socketService.on('admin_action', (data) {
    ref.invalidate(authProvider);
    // Tu peux afficher une notification locale ici si besoin
  });

  // Statistiques admin temps réel
  socketService.on('stats_update', (data) {
    ref.invalidate(adminStatsProvider(const StatsParams(period: 'day', nb: 30)));
    // Si tu utilises d'autres paramètres, adapte-les ici
  });

  // Ajoute ici d'autres events si besoin
});