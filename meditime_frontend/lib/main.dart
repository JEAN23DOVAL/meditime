import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

// On n'importe plus directement appRouter
// mais le provider qui expose notre GoRouter configuré
import 'package:meditime_frontend/providers/router_provider.dart'; //
import 'package:meditime_frontend/configs/app_theme.dart';
import 'package:meditime_frontend/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null); // Ajoute cette ligne
  runApp(
    const ProviderScope(child: MediTimeApp()),
  );
}

class MediTimeApp extends ConsumerWidget {
  const MediTimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupère le ThemeMode via notre themeNotifierProvider
    final themeMode = ref.watch(themeNotifierProvider);

    // Récupère le GoRouter configuré via routerProvider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MediTime',
      routerConfig: router,         // router dynamiquement fourni par Riverpod
      theme: AppTheme.lightTheme,   // thème clair
      darkTheme: AppTheme.darkTheme,// thème sombre
      themeMode: themeMode,         // géré par Riverpod
    );
  }
}