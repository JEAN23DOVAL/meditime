import 'package:flutter/material.dart';
import 'rdv_list.dart';
import 'package:meditime_frontend/configs/app_colors.dart';

class RdvStatusTabs extends StatelessWidget {
  final bool showPatientRdv;
  const RdvStatusTabs({required this.showPatientRdv, super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: AppColors.secondary,
            child: const TabBar(
              indicatorColor: AppColors.primary,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(icon: Icon(Icons.list), text: 'Tous'),
                Tab(icon: Icon(Icons.check_circle), text: 'Terminé'),
                Tab(icon: Icon(Icons.timelapse), text: 'En cours'),
                Tab(icon: Icon(Icons.cancel), text: 'Annulé'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: List.generate(4, (index) {
                final status = ['all', 'completed', 'ongoing', 'cancelled'][index];
                return RdvList(filter: status, showPatientRdv: showPatientRdv);
              }),
            ),
          ),
        ],
      ),
    );
  }
}