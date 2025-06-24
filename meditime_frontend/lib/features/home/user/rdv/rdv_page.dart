import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/user/rdv/widgets/rdv_bottom_sheet_content.dart';
import 'package:meditime_frontend/providers/rdv_badge_provider.dart';
import 'widgets/rdv_status_tabs.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';

const List<_RdvTab> rdvTabs = [
  _RdvTab(label: 'À venir', filter: 'upcoming', icon: Icons.schedule),
  _RdvTab(label: 'Terminé', filter: 'completed', icon: Icons.check_circle),
  _RdvTab(label: 'Annulé', filter: 'cancelled', icon: Icons.cancel),
  _RdvTab(label: 'Non honoré', filter: 'no_show', icon: Icons.block),
];

class _RdvTab {
  final String label;
  final String filter;
  final IconData icon;
  const _RdvTab({required this.label, required this.filter, required this.icon});
}

class RdvPage extends ConsumerWidget {
  const RdvPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDoctor = user.role == 'doctor';

    // Réinitialise le badge quand on ouvre la page RDV
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rdvBadgeProvider.notifier).clear();
    });

    if (!isDoctor) {
      // Patient : une seule TabBar (statuts)
      return DefaultTabController(
        length: rdvTabs.length,
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('Mes Rendez-vous'),
            centerTitle: true,
            backgroundColor: AppColors.secondary,
            bottom: TabBar(
              indicatorColor: AppColors.primary,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                for (final tab in rdvTabs)
                  Tab(icon: Icon(tab.icon), text: tab.label),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              for (final tab in rdvTabs)
                RdvStatusTabs(
                  showPatientRdv: false,
                  filter: tab.filter,
                  patientId: user.idUser,
                  doctorId: null,
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: FractionallySizedBox(
                    heightFactor: 0.85,
                    child: RdvBottomSheetContent(),
                  ),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      );
    }

    // Médecin : deux TabBar (niveau 1 = type de RDV, niveau 2 = statuts)
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
              Tab(icon: Icon(Icons.person), text: 'Mes RDV'),
              Tab(icon: Icon(Icons.people), text: 'Avec patients'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Onglet 1 : le médecin est patient
            _DoctorRdvTab(
              type: _DoctorRdvTabType.asPatient,
              userId: user.idUser,
              doctorId: null, // <-- Correction ici !
            ),
            // Onglet 2 : le médecin est médecin
            _DoctorRdvTab(
              type: _DoctorRdvTabType.asDoctor,
              userId: user.idUser,
              doctorId: user.idUser, // <-- CORRECTION : passe user.idUser ici !
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: FractionallySizedBox(
                  heightFactor: 0.85,
                  child: RdvBottomSheetContent(),
                ),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

enum _DoctorRdvTabType { asPatient, asDoctor }

class _DoctorRdvTab extends StatelessWidget {
  final _DoctorRdvTabType type;
  final int userId;
  final int? doctorId; // <-- change ici : int? au lieu de int
  const _DoctorRdvTab({
    required this.type,
    required this.userId,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: rdvTabs.length,
      child: Column(
        children: [
          Material(
            color: AppColors.secondary,
            child: TabBar(
              indicatorColor: AppColors.primary,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                for (final tab in rdvTabs)
                  Tab(icon: Icon(tab.icon), text: tab.label),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final tab in rdvTabs)
                  RdvStatusTabs(
                    showPatientRdv: type == _DoctorRdvTabType.asDoctor,
                    filter: tab.filter,
                    patientId: type == _DoctorRdvTabType.asPatient ? userId : null,
                    doctorId: type == _DoctorRdvTabType.asDoctor ? doctorId : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}