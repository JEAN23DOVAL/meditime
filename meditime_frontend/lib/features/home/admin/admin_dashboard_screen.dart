import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/admin/provider/admin_stats_provider.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_drawer.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_search_bar.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_summary_cards.dart';
import 'package:meditime_frontend/features/home/admin/provider/summary_provider.dart';
import 'package:meditime_frontend/features/home/admin/widgets/evolution_chart.dart';
import 'package:meditime_frontend/features/home/admin/stats/stats_params.dart'; // déjà présent

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsyncValue = ref.watch(summaryStatsProvider);

    return Scaffold(
      drawer: const AdminDrawer(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MediTime Admin',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              ref.invalidate(summaryStatsProvider); // <-- Ajoute ceci
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminSearchBar(),
              const SizedBox(height: 20),
              summaryAsyncValue.when(
                data: (summary) => AdminSummaryCards(
                  patients: summary['patients'] ?? 0,
                  doctors: summary['doctors'] ?? 0,
                  admins: summary['admins'] ?? 0,
                  totalUsers: summary['totalUsers'] ?? 0,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text("Erreur: $error")),
              ),
              const SizedBox(height: 30),
              // Déplace le Consumer ICI, pas dans les children du Column
              StatsSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// Ajoute ce widget dans le même fichier ou dans widgets/
class StatsSection extends ConsumerWidget {
  static const _params = StatsParams(period: 'day', nb: 30);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider(_params));
    return statsAsync.when(
      data: (stats) => Column(
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
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Erreur stats: $e'),
    );
  }
}