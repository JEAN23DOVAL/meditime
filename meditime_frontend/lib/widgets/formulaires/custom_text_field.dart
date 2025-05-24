// lib/shared/widgets/custom_text_field.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged; // Ajoute ce paramètre

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.onChanged, // Ajoute ici aussi
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged, // Passe-le ici
    );
  }
}

class CustomImagePickerField extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onPick;
  final String? errorText;

  const CustomImagePickerField({
    super.key,
    required this.label,
    required this.file,
    required this.onPick,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText == null ? AppColors.primary.withOpacity(0.2) : AppColors.error,
              ),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundLight,
            ),
            child: Center(
              child: Text(
                file == null ? label : 'Fichier sélectionné',
                style: TextStyle(
                  color: errorText == null ? AppColors.textDark : AppColors.error,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class CustomFilePickerField extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onPick;
  final String? errorText;

  const CustomFilePickerField({
    super.key,
    required this.label,
    required this.file,
    required this.onPick,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText == null ? AppColors.primary.withOpacity(0.2) : AppColors.error,
              ),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundLight,
            ),
            child: Center(
              child: Text(
                file == null ? label : 'Fichier sélectionné',
                style: TextStyle(
                  color: errorText == null ? AppColors.textDark : AppColors.error,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}