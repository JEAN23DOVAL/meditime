/*  
  * Ce fichier contient tous les styles de l'application.
  * Il utilise le package `flutter/material.dart` pour définir les styles.
  * Les styles sont organisés en classes pour une meilleure lisibilité et une utilisation cohérente dans toute l'application.
  * Les styles sont définis en utilisant le type `TextStyle` de Flutter.
*/

import 'package:flutter/material.dart';

/// TextStyles réutilisables partout dans l’app
class AppStyles {
  // Très grang titre (e.g. Connexion, Inscription)
  static const TextStyle heading0 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  // Titres principaux (e.g. Home, Dashboard)
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Sous-titres (e.g. titres de sections)
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Texte moyen (e.g. onboarding)
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  // Texte normal (paragraphe, labels)
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  // Texte plus petit (aide, annotations)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );
}