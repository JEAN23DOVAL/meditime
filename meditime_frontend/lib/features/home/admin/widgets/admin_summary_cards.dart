import 'package:flutter/material.dart';
import 'admin_summary_card.dart';

class AdminSummaryCards extends StatelessWidget {
  final int patients;
  final int doctors;
  final int admins;
  final int totalUsers;

  const AdminSummaryCards({
    super.key,
    required this.patients,
    required this.doctors,
    required this.admins,
    required this.totalUsers,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        AdminSummaryCard(title: "Patients", count: patients, icon: Icons.people, color: Colors.blue),
        AdminSummaryCard(title: "Médecins", count: doctors, icon: Icons.medical_services, color: Colors.green),
        AdminSummaryCard(title: "Admins", count: admins, icon: Icons.admin_panel_settings, color: Colors.orange),
        AdminSummaryCard(title: "Utilisateurs", count: totalUsers, icon: Icons.group, color: Colors.purple),
      ],
    );
  }
}