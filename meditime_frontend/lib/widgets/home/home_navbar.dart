import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/providers/rdv_badge_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:meditime_frontend/providers/barre_nav.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int messageCount; // Ajout d'une variable pour le compteur de messages

  const HomeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.messageCount = 0, // Valeur par défaut à 0
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onTap,
          selectedItemColor: const Color(0xFF36A9E1),
          unselectedItemColor: Colors.grey.withOpacity(0.7),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              label: 'Home', icon: Icon(Icons.home_rounded, size: 30),
            ),
            const BottomNavigationBarItem(
              label: 'Docteur', icon: Icon(Icons.medical_services, size: 30),
            ),
            BottomNavigationBarItem(
              icon: Consumer(
                builder: (context, ref, _) {
                  final badgeCount = ref.watch(rdvBadgeProvider);
                  return Stack(
                    children: [
                      const Icon(Icons.calendar_today, size: 30),
                      if (badgeCount > 0)
                        Positioned(
                          right: 0, top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              label: 'RDV',
            ),
            BottomNavigationBarItem(
              icon: Consumer(
                builder: (context, ref, _) {
                  final unread = ref.watch(userUnreadCountProvider('all'));
                  return badges.Badge(
                    showBadge: unread > 0,
                    badgeContent: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    child: const Icon(Icons.message),
                  );
                },
              ),
              label: 'Messages',
            ),
            const BottomNavigationBarItem(
              label: 'Profil', icon: Icon(MdiIcons.accountCog, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}