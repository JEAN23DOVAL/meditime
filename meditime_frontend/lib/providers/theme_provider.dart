/*  
  * Ce fichier contient le provider de thème de l'application.
  * Il utilise le package `flutter/material.dart` pour gérer les thèmes de l'application.
  * Le provider utilise Riverpod pour la gestion de l'état et des dépendances.
  * Il permet de basculer entre le thème clair et le thème sombre en fonction des préférences de l'utilisateur.
  * Le provider est encapsulé dans un `ChangeNotifierProvider`, ce qui permet de notifier les widgets lorsque le thème change.
  * Le provider utilise également le package `shared_preferences` pour stocker les préférences de thème de l'utilisateur.
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1. On crée un StateNotifier qui gère un ThemeMode
///    Un StateNotifier permet de loger de la logique métier
///    (ici le changement de thème) et d’exposer un état (ThemeMode).
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system); 
  // Initialisation : on prend la configuration système par défaut.
  // Tu peux changer ici en ThemeMode.light ou ThemeMode.dark si tu préfères.

  /// 2. Méthode pour passer en mode clair
  void setLightMode() {
    state = ThemeMode.light;
  }

  /// 3. Méthode pour passer en mode sombre
  void setDarkMode() {
    state = ThemeMode.dark;
  }

  /// 4. Méthode pour reprendre le mode système
  void setSystemMode() {
    state = ThemeMode.system;
  }

  /// 5. Méthode toggle : inverse clair <-> sombre
  ///    Si on est en system, on passe en light.
  void toggleTheme() {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }
}

/// 6. On expose ce ThemeNotifier via un StateNotifierProvider.
///    Ce provider nous donne à la fois le StateNotifier (pour appeler
///    les méthodes) et l’état (ThemeMode) à consommer.
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

/// 7. Pour simplifier la récupération du ThemeMode uniquement,
///    on peut aussi définir un alias (facultatif).
final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(themeNotifierProvider),
);