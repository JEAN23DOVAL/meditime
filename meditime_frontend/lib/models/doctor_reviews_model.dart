import 'user_model.dart';

class DoctorReview {
  final int id;
  final int doctorId;
  final int patientId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final User? patient; // <-- Ajouté

  DoctorReview({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.patient, // <-- Ajouté
  });

  factory DoctorReview.fromJson(Map<String, dynamic> json) => DoctorReview(
        id: json['id'],
        doctorId: json['doctor_id'],
        patientId: json['patient_id'],
        rating: json['rating'],
        comment: json['comment'],
        createdAt: DateTime.parse(json['created_at']),
        patient: json['patient'] != null ? User.fromMap(json['patient']) : null, // <-- Ajouté
      );
}