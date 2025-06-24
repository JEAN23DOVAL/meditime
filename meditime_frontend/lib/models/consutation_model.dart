class ConsultationFile {
  final int id;
  final String fileUrl;
  final String fileType;

  ConsultationFile({
    required this.id,
    required this.fileUrl,
    required this.fileType,
  });

  factory ConsultationFile.fromJson(Map<String, dynamic> json) => ConsultationFile(
        id: json['id'],
        fileUrl: json['file_url'],
        fileType: json['file_type'],
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_url': fileUrl,
      'file_type': fileType,
    };
  }
}

class ConsultationDetails {
  final int id;
  final int rdvId;
  final int patientId;
  final int doctorId;
  final String diagnostic;
  final String prescription;
  final String? doctorNotes;
  final List<ConsultationFile> files;

  ConsultationDetails({
    required this.id,
    required this.rdvId,
    required this.patientId,
    required this.doctorId,
    required this.diagnostic,
    required this.prescription,
    this.doctorNotes,
    required this.files,
  });

  factory ConsultationDetails.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ConsultationDetails(
      id: parseInt(json['id']),
      rdvId: parseInt(json['rdv_id']),
      patientId: parseInt(json['patient_id']),
      doctorId: parseInt(json['doctor_id']),
      diagnostic: json['diagnostic'] ?? '',
      prescription: json['prescription'] ?? '',
      doctorNotes: json['doctor_notes'],
      files: (json['files'] as List?)?.map((e) => ConsultationFile.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rdv_id': rdvId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'diagnostic': diagnostic,
      'prescription': prescription,
      'doctor_notes': doctorNotes,
      'files': files.map((e) => e.toJson()).toList(),
    };
  }
}