import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';

/// Bouton "Suivant"
class NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NextButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      label: const Text('Suivant'),
      icon: const Icon(Icons.arrow_forward),
    );
  }
}

/// Bouton "Passer"
class SkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SkipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text(
        'Skip',
        style: AppStyles.bodyText,
      ),
    );
  }
}

/// Boutons connexion
class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const LoginButton({
    super.key,
    required this.onPressed,
    this.label = 'Connexion',
    this.icon = Icons.lock,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label,
            style: AppStyles.heading3.copyWith(color: AppColors.textLight)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Boutons inscription
class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const RegisterButton({
    super.key,
    required this.onPressed,
    this.label = 'Inscription',
    this.icon = Icons.person_add,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary),
        label: Text(
          label,
          style: AppStyles.heading3.copyWith(color: AppColors.secondary),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

/// Grand bouton de navigation
class BigButton extends StatelessWidget {
  final VoidCallback? onPressed;   // Autoriser le null
  final String label;

  const BigButton({
    super.key,
    required this.onPressed,
    this.label = 'Big botton',
  });

  @override
  Widget build (BuildContext context){
    return SizedBox(
      width: double.infinity,
      child: 
      ElevatedButton(
        onPressed: onPressed, // Navigation via Riverpod
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            horizontal: 32, vertical: 16),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: AppStyles.heading2.copyWith(color: AppColors.textLight),
      ),
    ),
    );
  }
}

/// Bouton de retour dans un cercle sur font blanc
class BackButtonCircle extends StatelessWidget {
  final VoidCallback onPressed;

  const BackButtonCircle({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onPressed,
          child: Container(
            margin: const EdgeInsets.all(8), // Espacement autour du cercle
            decoration: const BoxDecoration(
              color: AppColors.secondary, // Couleur de fond du cercle
              shape: BoxShape.circle, // Forme circulaire
            ),
            child: const Icon(
              Icons.chevron_left, // Icône de retour
              color: AppColors.textLight, // Couleur de l'icône
              size: 40, // Taille de l'icône
            ),
          ),
        );
  }
}

/// Bouton d'action générique
class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, color: textColor ?? AppColors.textLight) : const SizedBox.shrink(),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: AppStyles.bodyText.copyWith(color: textColor ?? AppColors.textLight),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 2,
      ),
    );
  }
}

/// Bouton circulaire avec icône
class CircleIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const CircleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 50,
    this.backgroundColor = AppColors.primary,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: size * 0.7),
        ),
      ),
    );
  }
}

/// Bouton flottant personnalisé
class CustomFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String? tooltip;

  const CustomFloatingButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = AppColors.primary,
    this.iconColor = Colors.white,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
      child: Icon(icon, color: iconColor),
    );
  }
}