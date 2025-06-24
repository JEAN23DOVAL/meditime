class Patient {
  final int idUser;
  final String lastName;
  final String? firstName;
  final String email;
  final String? profilePhoto;
  final String? phone;
  final String? city;
  final String? gender;
  final String status; // 'active', 'inactive', 'suspended', etc.
  final bool isVerified;
  final DateTime? birthDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? suspensionReason;
  final int? suspendedBy;
  final DateTime? suspendedAt;
  final DateTime? deletedAt;

  Patient({
    required this.idUser,
    required this.lastName,
    this.firstName,
    required this.email,
    this.profilePhoto,
    this.phone,
    this.city,
    this.gender,
    required this.status,
    required this.isVerified,
    this.birthDate,
    this.createdAt,
    this.updatedAt,
    this.suspensionReason,
    this.suspendedBy,
    this.suspendedAt,
    this.deletedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    idUser: json['idUser'] ?? json['id'],
    lastName: json['lastName'] ?? '',
    firstName: json['firstName'],
    email: json['email'] ?? '',
    profilePhoto: json['profilePhoto'],
    phone: json['phone'],
    city: json['city'],
    gender: json['gender'],
    status: json['status'] ?? 'active',
    isVerified: json['isVerified'] ?? false,
    birthDate: json['birthDate'] != null ? DateTime.tryParse(json['birthDate']) : null,
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    suspensionReason: json['suspensionReason'],
    suspendedBy: json['suspendedBy'],
    suspendedAt: json['suspendedAt'] != null ? DateTime.tryParse(json['suspendedAt']) : null,
    deletedAt: json['deletedAt'] != null ? DateTime.tryParse(json['deletedAt']) : null,
  );
}