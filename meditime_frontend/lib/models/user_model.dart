import 'package:meditime_frontend/core/constants/api_endpoints.dart';

class User {
  final int idUser;
  final int? doctorId;
  final String lastName;
  final String? firstName;
  final String email;
  final String? profilePhoto;
  final DateTime? birthDate;
  final String? gender;
  final String? phone;
  final String? city;
  final String role;
  final bool isVerified;

  // Champs supplémentaires backend
  final String? status;
  final DateTime? lastLoginAt;
  final int? suspendedBy;
  final DateTime? suspendedAt;
  final String? suspensionReason;
  final DateTime? deletedAt;

  User({
    required this.idUser,
    this.doctorId,
    required this.lastName,
    this.firstName,
    required this.email,
    this.profilePhoto,
    this.birthDate,
    this.gender,
    this.phone,
    this.city,
    required this.role,
    required this.isVerified,
    this.status,
    this.lastLoginAt,
    this.suspendedBy,
    this.suspendedAt,
    this.suspensionReason,
    this.deletedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    String? photo = map['profilePhoto']?.toString();

    // Si c'est une URL complète, on adapte le host si besoin
    if (photo != null && photo.startsWith('http')) {
      // Récupère la base host dynamique selon l'appareil
      final uploadsBase = ApiConstants.uploadBaseUrl.replaceFirst('/uploads', '');
      // Remplace le host de l'URL par celui de l'appareil courant
      final uri = Uri.tryParse(photo);
      if (uri != null && uri.host != Uri.parse(uploadsBase).host) {
        // Remplace le host et le port par ceux de l'environnement courant
        photo = uri.replace(
          host: Uri.parse(uploadsBase).host,
          port: Uri.parse(uploadsBase).port,
        ).toString();
      }
    } else if (photo != null && photo.isNotEmpty) {
      // Si ce n'est pas une URL complète, utilise la logique habituelle
      photo = ApiConstants.getFileUrl(photo);
    }

    return User(
      idUser: map['idUser'] ?? map['id'] as int,
      doctorId: map['doctorId'] is int ? map['doctorId'] as int : null,
      lastName: map['lastName']?.toString() ?? '',
      firstName: map['firstName']?.toString(),
      email: map['email']?.toString() ?? '',
      profilePhoto: photo,
      birthDate: map['birthDate'] != null && map['birthDate'] != ''
          ? DateTime.tryParse(map['birthDate'].toString())
          : null,
      gender: map['gender']?.toString(),
      phone: map['phone']?.toString(),
      city: map['city']?.toString(),
      role: map['role']?.toString() ?? '',
      isVerified: map['isVerified'] == true || map['isVerified'] == 1,
      status: map['status']?.toString(),
      lastLoginAt: map['lastLoginAt'] != null && map['lastLoginAt'].toString().isNotEmpty
          ? DateTime.tryParse(map['lastLoginAt'].toString())
          : null,
      suspendedBy: map['suspendedBy'] is int ? map['suspendedBy'] as int : null,
      suspendedAt: map['suspendedAt'] != null && map['suspendedAt'].toString().isNotEmpty
          ? DateTime.tryParse(map['suspendedAt'].toString())
          : null,
      suspensionReason: map['suspensionReason']?.toString(),
      deletedAt: map['deletedAt'] != null && map['deletedAt'].toString().isNotEmpty
          ? DateTime.tryParse(map['deletedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'doctorId': doctorId,
      'lastName': lastName,
      'firstName': firstName,
      'email': email,
      'profilePhoto': profilePhoto,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'city': city,
      'role': role,
      'isVerified': isVerified,
      // Champs supplémentaires
      'status': status,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'suspendedBy': suspendedBy,
      'suspendedAt': suspendedAt?.toIso8601String(),
      'suspensionReason': suspensionReason,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  // Getter dynamique pour la spécialité (utile pour les médecins dans les contacts RDV)
  String? get specialite {
    // ignore: unnecessary_cast
    final map = this as dynamic;
    // Si la spécialité a été ajoutée dynamiquement (depuis le backend)
    if (map is Map && map.containsKey('specialite')) {
      return map['specialite']?.toString();
    }
    // Si l'objet a un champ spécialité (parfois injecté dynamiquement)
    if ((map as Object?) != null && (map as dynamic).specialite != null) {
      return (map as dynamic).specialite as String?;
    }
    return null;
  }
}