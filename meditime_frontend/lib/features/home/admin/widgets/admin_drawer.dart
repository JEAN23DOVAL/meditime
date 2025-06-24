import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/services/logout_service.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:badges/badges.dart' as badges;
import 'package:meditime_frontend/providers/barre_nav.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    ImageProvider avatarProvider;
    if (user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty) {
      avatarProvider = NetworkImage(user.profilePhoto!);
    } else {
      avatarProvider = const AssetImage('assets/images/avatar.png');
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: avatarProvider,
            ),
            accountName: Text(
              user != null
                  ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()
                  : "Admin",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            accountEmail: Text(
              user?.email ?? "admin@meditime.com",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),
          _drawerItem(context, icon: Icons.dashboard, label: "Dashboard", route: AppRoutes.adminDashboard),
          _drawerItem(context, icon: Icons.people, label: "Patients", route: AppRoutes.patientScreen),
          _drawerItem(context, icon: Icons.medical_services, label: "Médecins", route: AppRoutes.medecinList),
          _drawerItem(
            context,
            icon: Icons.admin_panel_settings,
            label: "Admins",
            route: AppRoutes.adminManagement,
          ),
          _drawerItem(
            context,
            icon: Icons.message,
            label: "Messages",
            route: AppRoutes.adminMessages,
            trailing: Consumer(
              builder: (context, ref, _) {
                final unread = ref.watch(adminUnreadCountProvider);
                return unread > 0
                    ? badges.Badge(
                        showBadge: true,
                        badgeContent: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10)),
                        child: const SizedBox(width: 24, height: 24),
                      )
                    : const SizedBox(width: 24, height: 24);
              },
            ),
          ),
          _drawerItem(context, icon: Icons.calendar_month, label: "Rendez-vous", route: AppRoutes.adminRdv),
          _drawerItem(context, icon: Icons.bar_chart, label: "Statistiques", route: AppRoutes.adminStats),
          _drawerItem(context, icon: Icons.settings, label: "Gestion de l'app"),
          const Spacer(),
          const Divider(),
          _drawerItem(context, icon: Icons.logout, label: "Déconnexion", color: Colors.red, ref: ref),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, {required IconData icon, required String label, Color? color, String? route, WidgetRef? ref, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(label, style: TextStyle(color: color ?? Colors.black87)),
      trailing: trailing,
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
            Navigator.of(context).pop();
            Future.microtask(() {
              final router = GoRouter.of(context);
              handleLogout(ref, router);
            });
          }
        } else {
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