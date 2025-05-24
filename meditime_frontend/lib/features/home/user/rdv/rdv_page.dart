import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'widgets/rdv_status_tabs.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_colors.dart';

class RdvPage extends StatelessWidget {
  final bool isDoctor;
  const RdvPage({required this.isDoctor, super.key});

  @override
  Widget build(BuildContext context) {
    return isDoctor ? _buildDoctorView() : _buildPatientView();
  }

  Widget _buildDoctorView() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Rendez-vous'),
          centerTitle: true,
          backgroundColor: AppColors.secondary,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'Mes RDV'),
              Tab(icon: Icon(Icons.people), text: 'Patients'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RdvStatusTabs(showPatientRdv: false),
            RdvStatusTabs(showPatientRdv: true),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {/* Nouveau RDV */},
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPatientView() {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mes Rendez-vous'),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
      ),
      body: const RdvStatusTabs(showPatientRdv: false),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () => context.go(AppRoutes.rendezVous),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}