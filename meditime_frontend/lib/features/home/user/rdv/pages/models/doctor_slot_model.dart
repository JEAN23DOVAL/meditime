class DoctorSlot {
  final int? id;
  final int doctorId;
  final String startDay;
  final int startHour;
  final int startMinute;
  final String endDay;
  final int endHour;
  final int endMinute;
  final String? status; // <-- Ajoute ce champ
  final DateTime? createdAt;

  const DoctorSlot({
    this.id,
    required this.doctorId,
    required this.startDay,
    required this.startHour,
    required this.startMinute,
    required this.endDay,
    required this.endHour,
    required this.endMinute,
    this.status, // <-- Ajoute ce champ
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'doctorId': doctorId,
    'startDay': startDay,
    'startHour': startHour,
    'startMinute': startMinute,
    'endDay': endDay,
    'endHour': endHour,
    'endMinute': endMinute,
    if (status != null) 'status': status, // <-- Ajoute ce champ
  };

  factory DoctorSlot.fromJson(Map<String, dynamic> json) => DoctorSlot(
    id: json['id'],
    doctorId: json['doctorId'],
    startDay: json['startDay'],
    startHour: json['startHour'],
    startMinute: json['startMinute'],
    endDay: json['endDay'],
    endHour: json['endHour'],
    endMinute: json['endMinute'],
    status: json['status'], // <-- Ajoute ce champ
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'])
        : null,
  );
}