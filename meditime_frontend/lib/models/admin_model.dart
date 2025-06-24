class AdminModel {
  final int id;
  final int userId;
  final String adminRole;
  final String? firstName;
  final String? lastName;
  final String email;
  final String status;

  AdminModel({
    required this.id,
    required this.userId,
    required this.adminRole,
    this.firstName,
    this.lastName,
    required this.email,
    required this.status,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
    id: json['id'],
    userId: json['userId'],
    adminRole: json['adminRole'],
    firstName: json['user']?['firstName'],
    lastName: json['user']?['lastName'],
    email: json['user']?['email'] ?? '',
    status: json['user']?['status'] ?? '',
  );
}