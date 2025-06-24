class Medecin {
  final int id;
  final int idUser;
  final String specialite;
  final String diplomes;
  final String numeroInscription;
  final String hopital;
  final String adresseConsultation;
  final String? cniFront;
  final String? cniBack;
  final String? certification;
  final String? cvPdf;
  final String? casierJudiciaire;
  final String status;
  final String? adminMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MedecinUser? user; // Ajouté

  Medecin({
    required this.id,
    required this.idUser,
    required this.specialite,
    required this.diplomes,
    required this.numeroInscription,
    required this.hopital,
    required this.adresseConsultation,
    this.cniFront,
    this.cniBack,
    this.certification,
    this.cvPdf,
    this.casierJudiciaire,
    required this.status,
    this.adminMessage,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Medecin.fromJson(Map<String, dynamic> json) => Medecin(
        id: json['id'],
        idUser: json['idUser'],
        specialite: json['specialite'],
        diplomes: json['diplomes'],
        numeroInscription: json['numero_inscription'],
        hopital: json['hopital'],
        adresseConsultation: json['adresse_consultation'],
        cniFront: json['cni_front'],
        cniBack: json['cni_back'],
        certification: json['certification'],
        cvPdf: json['cv_pdf'],
        casierJudiciaire: json['casier_judiciaire'],
        status: json['status'],
        adminMessage: json['admin_message'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        user: json['user'] != null ? MedecinUser.fromJson(json['user']) : null,
      );
}

class MedecinUser {
  final int idUser;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? profilePhoto;
  final String? status;

  MedecinUser({
    required this.idUser,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.profilePhoto,
    this.status,
  });

  factory MedecinUser.fromJson(Map<String, dynamic> json) => MedecinUser(
        idUser: json['idUser'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        phone: json['phone'],
        profilePhoto: json['profilePhoto'],
        status: json['status'],
      );
}