import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_drawer.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_search_bar.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_summary_cards.dart';
import 'package:meditime_frontend/features/home/admin/provider/summary_provider.dart';

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
              const Text(
                "Statistiques et autres sections à venir...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}