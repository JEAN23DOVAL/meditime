/* 
  * Ce fichier contient la configuration du thème de l'application.
  * Il utilise le package `flutter/material.dart` pour définir les styles de l'application.
  * Le thème est divisé en deux parties : le thème clair et le thème sombre.
  * Chaque partie définit les couleurs, les polices et d'autres propriétés visuelles.
  * Le thème clair est utilisé par défaut, mais le thème sombre peut être activé en fonction des préférences de l'utilisateur ou des paramètres du système.
*/

import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';

/// Contient les configurations des thèmes clair & sombre
class AppTheme {
  /// Thème clair
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,

    // Palette de couleurs
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.backgroundLight,
      error: AppColors.error,
      onPrimary: AppColors.textLight,
      onBackground: AppColors.textDark,
      onSecondary: AppColors.textLight,
    ),

    // Barre d'applications
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.textLight,
      elevation: 0,
    ),

    // Texte global
    textTheme: const TextTheme(
      displayLarge: AppStyles.heading1,
      headlineMedium: AppStyles.heading2,
      bodyLarge: AppStyles.bodyText,
      bodyMedium: AppStyles.bodyText,
      bodySmall: AppStyles.caption,
    ),

    // Champs de saisie
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
      errorStyle: const TextStyle(color: AppColors.error),
    ),

    // Boutons élevés (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  /// Thème sombre
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.textDark,

    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.textDark,
      error: AppColors.error,
      onPrimary: AppColors.textLight,
      onBackground: AppColors.textLight,
      onSecondary: AppColors.textLight,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.textLight,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      displayLarge: AppStyles.heading1,
      headlineMedium: AppStyles.heading2,
      bodyLarge: AppStyles.bodyText,
      bodyMedium: AppStyles.bodyText,
      bodySmall: AppStyles.caption,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.secondary),
      ),
      errorStyle: const TextStyle(color: AppColors.error),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}