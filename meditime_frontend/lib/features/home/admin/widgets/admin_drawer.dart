import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/services/logout_service.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/admin_avatar.png'),
            ),
            accountName: const Text("Admin Name"),
            accountEmail: const Text("admin@meditime.com"),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),
          _drawerItem(context, icon: Icons.dashboard, label: "Dashboard", route: AppRoutes.adminDashboard),
          _drawerItem(context, icon: Icons.people, label: "Patients"),
          _drawerItem(context, icon: Icons.medical_services, label: "Médecins", route: AppRoutes.medecinList),
          _drawerItem(context, icon: Icons.admin_panel_settings, label: "Admins"),
          _drawerItem(context, icon: Icons.message, label: "Messages", route: AppRoutes.adminMessages),
          _drawerItem(context, icon: Icons.calendar_month, label: "Rendez-vous"),
          _drawerItem(context, icon: Icons.bar_chart, label: "Statistiques"),
          _drawerItem(context, icon: Icons.settings, label: "Gestion de l'app"),
          const Spacer(),
          const Divider(),
          _drawerItem(context, icon: Icons.logout, label: "Déconnexion", color: Colors.red, ref: ref),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, {required IconData icon, required String label, Color? color, String? route, WidgetRef? ref}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(label, style: TextStyle(color: color ?? Colors.black87)),
      onTap: () async {
        if (label == "Déconnexion" && ref != null) {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Déconnexion'),
              content: const Text('Voulez-vous quitter l\'application ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF36A9E1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          if (shouldLogout == true) {
            // Ferme le Drawer AVANT de naviguer
            Navigator.of(context).pop();
            Future.microtask(() {
              final router = GoRouter.of(context);
              handleLogout(ref, router);
            });
          }
        } else {
          // Pour les autres routes, ferme le Drawer puis navigue
          Navigator.of(context).pop();
          if (route != null) {
            Future.microtask(() {
              context.go(route);
            });
          }
        }
      },
    );
  }
}