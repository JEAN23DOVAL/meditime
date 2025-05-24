/*  
  * Ce fichier contient toutes les couleurs utilisées dans l'application.
  * Il utilise le package `flutter/material.dart` pour définir les couleurs.
  * Les couleurs sont organisées en classes pour une meilleure lisibilité et une utilisation cohérente dans toute l'application.
  * Les couleurs sont définies en utilisant le type `Color` de Flutter.
*/

import 'package:flutter/material.dart';

/// Définit toutes les couleurs de l'application
class AppColors {
  // Couleur principale (boutons, actions primaires)
  static const Color primary = Color(0xFF36A9E1);

  // Couleur secondaire (appBar, éléments forts)
  static const Color secondary = Color(0xFF312783);

  // Fond clair général (soft background)
  static const Color backgroundLight = Color(0xFFF5F9FC);

  // Texte principal (foncé)
  static const Color textDark = Color(0xFF222B45);

  // Texte clair/inversé (sur fond sombre ou boutons)
  static const Color textLight = Color(0xFFFFFFFF);

  // Accent "santé" pour succès, validation
  static const Color success = Color(0xFF3BCB77);

  // Couleur d’erreur/alerte
  static const Color error = Color(0xFFFF5C5C);
}