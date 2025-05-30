import 'user_model.dart';

class Rdv {
  final int id;
  final int patientId;
  final int doctorId;
  final int? doctorTableId; // <-- Ajoute ce champ
  final String specialty;
  final DateTime date;
  final String status;
  final String? motif;
  final int durationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? patient;
  final User? doctor; // <-- C'est un User, pas un Doctor
  // Pas besoin d'objet Doctor ici, car doctorInfo ne contient que l'id

  Rdv({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.doctorTableId,
    required this.specialty,
    required this.date,
    required this.status,
    this.motif,
    required this.durationMinutes,
    required this.createdAt,
    required this.updatedAt,
    this.patient,
    this.doctor,
  });

  factory Rdv.fromJson(Map<String, dynamic> json) => Rdv(
        id: json['id'],
        patientId: json['patient_id'],
        doctorId: json['doctor_id'],
        doctorTableId: json['doctor_table_id'], // <-- Ajoute ce champ
        specialty: json['specialty'],
        date: DateTime.parse(json['date']),
        status: json['status'],
        motif: json['motif'],
        durationMinutes: json['duration_minutes'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        patient: json['patient'] != null ? User.fromMap(json['patient']) : null,
        doctor: json['doctor'] != null ? User.fromMap(json['doctor']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'doctor_id': doctorId,
        'specialty': specialty,
        'date': date.toIso8601String(),
        'status': status,
        'motif': motif,
        'duration_minutes': durationMinutes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}