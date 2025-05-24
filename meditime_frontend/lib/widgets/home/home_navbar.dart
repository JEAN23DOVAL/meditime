import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
            const BottomNavigationBarItem(
              label: 'RDV', icon: Icon(Icons.calendar_today, size: 30),
            ),
            BottomNavigationBarItem(
              label: 'Messages',
              icon: Stack(
                children: [
                  const Icon(MdiIcons.message, size: 30),
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$messageCount', // Utilisation de la variable messageCount
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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