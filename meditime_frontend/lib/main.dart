import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import 'package:meditime_frontend/features/home/user/messages/widgets/message_detail_page.dart';
import 'package:meditime_frontend/providers/router_provider.dart';
import 'package:meditime_frontend/configs/app_theme.dart';
import 'package:meditime_frontend/providers/theme_provider.dart';
import 'package:meditime_frontend/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart'; // Ajoute cet import
import 'package:meditime_frontend/core/network/socket_service.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';
import 'package:meditime_frontend/providers/socket_provider.dart';

/* final socketGlobalListenerProvider = Provider<void>((ref) {
  final socketService = ref.read(socketServiceProvider);

  // RDV: écoute les updates et rafraîchit tous les providers concernés
  socketService.on('rdv_update', (data) {
    ref.invalidate(rdvListProvider);
    ref.invalidate(nextPatientRdvProvider);
    ref.invalidate(nextDoctorRdvProvider);
    // Si tu as d'autres providers à invalider, ajoute-les ici
  });

  // Ajoute ici d'autres events si besoin (ex: doctor_profile_update)
  // socketService.on('doctor_profile_update', (data) { ... });

  // Tu peux aussi écouter d'autres events pour d'autres modules
}); */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('fr_FR', null);
  await ApiConstants.initBaseUrl();
  runApp(const ProviderScope(child: MediTimeApp()));
}

class MediTimeApp extends ConsumerStatefulWidget {
  const MediTimeApp({super.key});

  @override
  ConsumerState<MediTimeApp> createState() => _MediTimeAppState();
}

class _MediTimeAppState extends ConsumerState<MediTimeApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.init(ref);
    Future.microtask(() => ref.read(socketServiceProvider).connect());

    // Handler pour notification locale (quand payload est conversationId)
    FlutterLocalNotificationsPlugin().initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          final parts = payload.split('|');
          if (parts.length == 2) {
            final type = parts[0];
            final id = int.tryParse(parts[1]);
            if (type == 'consultation' && id != null) {
              // Navigue vers la page consultation
            }
            if (type == 'rdv' && id != null) {
              // Navigue vers la page RDV
            }
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Active le listener global socket
    ref.watch(socketGlobalListenerProvider);

    final themeMode = ref.watch(themeNotifierProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MediTime',
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
    );
  }
}