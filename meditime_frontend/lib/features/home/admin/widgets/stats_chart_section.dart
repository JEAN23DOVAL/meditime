import 'package:flutter/material.dart';
import 'package:meditime_frontend/features/home/admin/widgets/evolution_chart.dart';

class StatsChartSection extends StatelessWidget {
  final Map<String, dynamic> stats;
  final String period;

  const StatsChartSection({super.key, required this.stats, required this.period});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegistrationsBarChart(
            data: List<Map<String, dynamic>>.from(stats['registrations'] ?? []),
            title: "Inscriptions par rôle (30j)",
            roles: const ['patient', 'doctor', 'admin'],
            roleColors: const [Colors.blue, Colors.green, Colors.orange],
          ),
        RdvLineChart(
          data: List<Map<String, dynamic>>.from(stats['rdvs'] ?? []),
          title: "Rendez-vous créés (30j)",
          color: Colors.purple,
        ),
        SimpleLineChart(
          data: List<Map<String, dynamic>>.from(stats['consultations'] ?? []),
          title: "Consultations effectuées (30j)",
          color: Colors.teal,
          area: true,
        ),
        SimpleBarChart(
          data: List<Map<String, dynamic>>.from(stats['reviews'] ?? []),
          title: "Avis laissés (30j)",
          color: Colors.amber,
        ),
        SimpleBarChart(
          data: List<Map<String, dynamic>>.from(stats['doctorApplications'] ?? []),
          title: "Demandes de médecins (30j)",
          color: Colors.deepOrange,
        ),
        SimpleLineChart(
          data: List<Map<String, dynamic>>.from(stats['messages'] ?? []),
          title: "Messages envoyés (30j)",
          color: Colors.blueGrey,
          area: true,
        ),
        StackedBarChart(
          data: List<Map<String, dynamic>>.from(stats['rdvStatusStats'] ?? []),
          title: "RDV par statut (30j)",
          statuses: const ['pending', 'confirmed', 'completed', 'cancelled', 'no_show', 'doctor_no_show', 'expired'],
          statusColors: const [
            Colors.orange, Colors.blue, Colors.green, Colors.red, Colors.deepOrange, Colors.brown, Colors.grey
          ],
        ),
        StackedBarChart(
          data: List<Map<String, dynamic>>.from(stats['doctorApplicationsStatus'] ?? []),
          title: "Statuts des demandes médecins (30j)",
          statuses: const ['pending', 'accepted', 'refused'],
          statusColors: const [Colors.orange, Colors.green, Colors.red],
        ),
        SingleValueCard(
          value: stats['activeDoctors'] ?? 0,
          title: "Médecins actifs sur la période",
          icon: Icons.medical_services,
          color: Colors.blue,
        ),
        Row(
          children: [
            Expanded(
              child: DonutChart(
                value: (stats['noShowRate'] ?? 0).toDouble(),
                title: "Taux de no-show",
                color: Colors.orange,
                label: "No-show",
              ),
            ),
            Expanded(
              child: DonutChart(
                value: (stats['cancellationRate'] ?? 0).toDouble(),
                title: "Taux d'annulation",
                color: Colors.red,
                label: "Annulation",
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- Exemple d'implémentation pour les widgets de chart ---
/* class RegistrationsBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final List<String> roles;
  final List<Color> roleColors;
  final VoidCallback? onDetails;

  const RegistrationsBarChart({
    super.key,
    required this.data,
    required this.title,
    required this.roles,
    required this.roleColors,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: onDetails != null
                ? IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: onDetails,
                  )
                : null,
          ),
          // ... ici ton widget de bar chart ...
          const SizedBox(height: 120, child: Center(child: Text('BarChart à implémenter'))),
        ],
      ),
    );
  }
} */

/* class RdvLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final Color color;
  final VoidCallback? onDetails;

  const RdvLineChart({
    super.key,
    required this.data,
    required this.title,
    required this.color,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: onDetails != null
                ? IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: onDetails,
                  )
                : null,
          ),
          // ... ici ton widget de line chart ...
          const SizedBox(height: 120, child: Center(child: Text('LineChart à implémenter'))),
        ],
      ),
    );
  }
} */