import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/user/providers/user_message_provider.dart';
import 'package:meditime_frontend/providers/rdv_badge_provider.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static late WidgetRef _ref;

  static Future<void> init(WidgetRef ref) async {
    _ref = ref;
    // Initialisation locale
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        final actionId = details.actionId;
        final rdvId = int.tryParse(details.payload ?? '');
        if (actionId != null && rdvId != null) {
          handleNotificationAction(actionId, rdvId, _ref);
        }
      },
    );

    // Demande la permission (iOS/Android 13+)
    await FirebaseMessaging.instance.requestPermission();

    // Foreground : affiche notification locale
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);

      if (message.data['type'] == 'rdv') {
        _ref.read(rdvBadgeProvider.notifier).increment();
        _ref.invalidate(rdvListProvider);
      }
      if (message.data['type'] == 'rdv_reminder') {
        // Affiche une notif locale personnalisée
        showRdvReminderNotification(message.data);
        _ref.read(rdvBadgeProvider.notifier).increment();
        _ref.invalidate(rdvListProvider);
      }
      if (message.data['type'] == 'consultation') {
        showConsultationNotification(message.data);
        // Tu peux aussi invalider un provider de consultations ici si besoin
        // _ref.invalidate(consultationByRdvProvider(int.parse(message.data['rdvId'])));
      }
      if (message.data['type'] == 'message') {
        _ref.invalidate(userMessagesProvider('all'));
        _ref.invalidate(userMessagesProvider('doctor'));
        _ref.invalidate(userMessagesProvider('admin'));
        showMessageNotification(message.data);
      }
    });

    // Notification cliquée (app ouverte)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Gère la navigation selon message.data['route'] ou autre
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    final status = data['status'];
    final rdvId = int.tryParse(data['rdvId'] ?? '');

    List<AndroidNotificationAction> actions = [];

    // Détermine les actions selon le statut
    if (status == 'pending') {
      actions = [
        const AndroidNotificationAction('ACCEPT', 'Accepter'),
        const AndroidNotificationAction('REFUSE', 'Refuser'),
      ];
    } else if (status == 'upcoming') {
      // Pas d'action pour le patient, mais tu pourrais ajouter "Annuler" pour le patient
    } else if (status == 'cancelled' || status == 'refused' || status == 'expired' || status == 'completed') {
      // Pas d'action, juste info
    } else if (status == 'no_show' || status == 'doctor_no_show') {
      // Pas d'action, juste info
    }

    final androidDetails = AndroidNotificationDetails(
      'rdv_channel',
      'Notifications RDV',
      importance: Importance.max,
      priority: Priority.high,
      actions: actions,
    );
    final iosDetails = const DarwinNotificationDetails();

    await _localNotifications.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: data['rdvId'], // Pour navigation ou action
    );
  }

  static Future<String?> getFcmToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  // Ajoute ce handler pour les actions sur notification
  static void handleNotificationAction(String actionId, int rdvId, WidgetRef ref) {
    final notifier = ref.read(rdvActionProvider.notifier);
    if (actionId == 'ACCEPT') {
      notifier.accept(rdvId);
    } else if (actionId == 'REFUSE') {
      notifier.refuse(rdvId);
    }
    // Ajoute d'autres actions si besoin
  }

  static Future<void> showMessageNotification(Map<String, dynamic> data) async {
    final title = data['senderName'] ?? 'Nouveau message';
    final content = data['body'] ?? data['content'] ?? '';
    final androidDetails = AndroidNotificationDetails(
      'message_channel',
      'Messages',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = const DarwinNotificationDetails();

    await _localNotifications.show(
      data['messageId']?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title,
      content,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: data['conversationId'], // Pour navigation directe
    );
  }

  static Future<void> showRdvReminderNotification(Map<String, dynamic> data) async {
    final title = data['title'] ?? 'Rappel RDV';
    final body = data['body'] ?? 'Vous avez un rendez-vous à venir.';
    final androidDetails = AndroidNotificationDetails(
      'rdv_reminder_channel',
      'Rappels RDV',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = const DarwinNotificationDetails();

    await _localNotifications.show(
      data['rdvId']?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: data['rdvId'],
    );
  }

  static Future<void> showConsultationNotification(Map<String, dynamic> data) async {
    final title = data['title'] ?? 'Consultation';
    final body = data['body'] ?? 'Un compte-rendu de consultation est disponible.';
    final androidDetails = AndroidNotificationDetails(
      'consultation_channel',
      'Consultations',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = const DarwinNotificationDetails();

    await _localNotifications.show(
      data['consultationId']?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: data['consultationId'],
    );
  }
}