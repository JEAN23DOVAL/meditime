import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class KPICard extends StatelessWidget {
  final String label;
  final dynamic value;
  final IconData icon;
  final Color color;
  final String? trend; // ex: "+12%"

  const KPICard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: trend != null ? Text('Évolution: $trend', style: TextStyle(color: color)) : null,
        trailing: Text(
          '$value',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}

// Section de KPIs groupés
class KPICardSection extends StatelessWidget {
  final Map<String, dynamic> stats;
  final Map<String, dynamic> summary; // Ajoute ce paramètre

  const KPICardSection({super.key, required this.stats, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        KPICard(
          label: "Utilisateurs inscrits",
          value: summary['totalUsers'] ?? '-',
          icon: Icons.group,
          color: Colors.deepPurple,
        ),
        KPICard(
          label: "Patients",
          value: summary['patients'] ?? '-',
          icon: Icons.people,
          color: Colors.blue,
        ),
        KPICard(
          label: "Médecins",
          value: summary['doctors'] ?? '-',
          icon: Icons.medical_services,
          color: Colors.green,
        ),
        KPICard(
          label: "Admins",
          value: summary['admins'] ?? '-',
          icon: Icons.admin_panel_settings,
          color: Colors.orange,
        ),
        KPICard(
          label: "RDV créés",
          value: stats['rdvs'] != null && stats['rdvs'] is List && stats['rdvs'].isNotEmpty
              ? stats['rdvs'].map((e) => e['count'] as int).reduce((a, b) => a + b)
              : '-',
          icon: Icons.calendar_month,
          color: Colors.purple,
        ),
        KPICard(
          label: "Consultations",
          value: stats['consultations'] != null && stats['consultations'] is List && stats['consultations'].isNotEmpty
              ? stats['consultations'].map((e) => e['count'] as int).reduce((a, b) => a + b)
              : '-',
          icon: MdiIcons.stethoscope,
          color: Colors.teal,
        ),
        KPICard(
          label: "Taux no-show",
          value: stats['noShowRate'] != null ? "${stats['noShowRate'].toStringAsFixed(1)}%" : '-',
          icon: Icons.not_interested,
          color: Colors.orange,
        ),
        KPICard(
          label: "Taux annulation",
          value: stats['cancellationRate'] != null ? "${stats['cancellationRate'].toStringAsFixed(1)}%" : '-',
          icon: Icons.cancel,
          color: Colors.red,
        ),
      ],
    );
  }
}