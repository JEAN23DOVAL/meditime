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
  });

  factory User.fromMap(Map<String, dynamic> map) {
    String? photo = map['profilePhoto']?.toString();
    if (photo != null && photo.isNotEmpty && !photo.startsWith('http')) {
      photo = 'http://10.0.2.2:3000/uploads/photo_profil/$photo';
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
    };
  }
}