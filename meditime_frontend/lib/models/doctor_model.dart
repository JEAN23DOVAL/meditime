import 'user_model.dart';

class Doctor {
  final int id;
  final int idUser;
  final String specialite;
  final String diplomes;
  final String numeroInscription;
  final String hopital;
  final String adresseConsultation;
  final double note; // jamais null
  final DateTime createdAt;
  final User? user;

  // Nouveaux champs
  final int? patientsExamined;
  final int? experienceYears;
  final int? pricePerHour;
  final String? description;

  Doctor({
    required this.id,
    required this.idUser,
    required this.specialite,
    required this.diplomes,
    required this.numeroInscription,
    required this.hopital,
    required this.adresseConsultation,
    required this.note,
    required this.createdAt,
    this.user,
    this.patientsExamined,
    this.experienceYears,
    this.pricePerHour,
    this.description,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      idUser: json['idUser'],
      specialite: json['specialite'],
      diplomes: json['diplomes'],
      numeroInscription: json['numero_inscription'],
      hopital: json['hopital'],
      adresseConsultation: json['adresse_consultation'],
      note: (json['note'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromMap(json['user']) : null,
      patientsExamined: json['patientsExamined'],
      experienceYears: json['experienceYears'],
      pricePerHour: json['pricePerHour'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUser': idUser,
      'specialite': specialite,
      'diplomes': diplomes,
      'numero_inscription': numeroInscription,
      'hopital': hopital,
      'adresse_consultation': adresseConsultation,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'patientsExamined': patientsExamined,
      'experienceYears': experienceYears,
      'pricePerHour': pricePerHour,
      'description': description,
      'user': user?.toMap(),
    };
  }
}