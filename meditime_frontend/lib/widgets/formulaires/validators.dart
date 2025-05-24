// lib/shared/utils/validators.dart

import 'dart:io';

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez entrer votre nom';
    if (value.length < 3) return 'Doit contenir au moins 3 caractères';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez entrer votre e-mail';
    final emailRegExp = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    if (!emailRegExp.hasMatch(value)) return 'Veuillez entrer une adresse e-mail valide';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
    if (value.length < 8) return 'Minimum 8 caractères';
    if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) return 'Une majuscule requise';
    if (!RegExp(r'^(?=.*[0-9])').hasMatch(value)) return 'Un chiffre requis';
    if (!RegExp(r'^(?=.*[!@#\$%^&*(),.?":{}|<>])').hasMatch(value)) {
      return 'Un caractère spécial requis';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Veuillez confirmer le mot de passe';
    if (value != original) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  static String? validateCode(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez entrer le code';
    if (value.trim().length != 6) return 'Le code doit contenir 6 chiffres';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Code invalide';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez entrer un numéro de téléphone';
    if (!RegExp(r'^\d{9}$').hasMatch(value)) return 'Le numéro doit contenir exactement 9 chiffres';

    // Numéros fixes : 222, 233, 242, 243
    final fixed = ['222', '233', '242', '243'];
    if (fixed.contains(value.substring(0, 3))) return null;

    // Mobiles : commence par 6
    if (!value.startsWith('6')) return 'Le numéro mobile doit commencer par 6';
    final prefix2 = value.substring(1, 3);
    final prefix3 = value.substring(1, 4);

    bool valid = false;
    // MTN : 50–54, 70–79, 80–83
    final mtn2 = List.generate(5, (i) => (50 + i).toString()) +
        List.generate(10, (i) => (70 + i).toString()) +
        List.generate(4, (i) => (80 + i).toString());
    // Orange : 55–59, 90–99
    final orange2 = List.generate(5, (i) => (55 + i).toString()) +
        List.generate(10, (i) => (90 + i).toString());
    // Orange 3-digit: 860–879, 880–889
    final orange3 = List.generate(20, (i) => (860 + i).toString()) +
        List.generate(10, (i) => (880 + i).toString());
    // Camtel : 20–29 (après 6? assume fixed starts '62')
    final camtel2 = List.generate(10, (i) => (20 + i).toString());

    if (mtn2.contains(prefix2) || orange2.contains(prefix2) || camtel2.contains(prefix2)) valid = true;
    if (orange3.contains(prefix3)) valid = true;

    return valid ? null : 'Préfixe non autorisé';
  }

  static String? validateImageFile(File? file, {required String label, int maxSizeMB = 5}) {
    if (file == null) return '$label est requis';
    final allowedExtensions = ['.jpg', '.jpeg', '.png'];
    if (!allowedExtensions.any((ext) => file.path.endsWith(ext))) {
      return 'Format de fichier invalide pour $label';
    }
    final fileSizeInMB = file.lengthSync() / (1024 * 1024);
    if (fileSizeInMB > maxSizeMB) return '$label ne doit pas dépasser $maxSizeMB Mo';
    return null;
  }

  static String? validatePdfFile(File? file, {required String label, int maxSizeMB = 5}) {
    if (file == null) return '$label est requis';
    if (!file.path.toLowerCase().endsWith('.pdf')) {
      return 'Format de fichier invalide. Seuls les fichiers PDF sont autorisés pour $label';
    }
    final fileSizeInMB = file.lengthSync() / (1024 * 1024);
    if (fileSizeInMB > maxSizeMB) return '$label ne doit pas dépasser $maxSizeMB Mo';
    return null;
  }
}