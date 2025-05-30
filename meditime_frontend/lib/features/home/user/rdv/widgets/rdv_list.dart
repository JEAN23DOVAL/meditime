import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';
import 'rdv_card.dart';

class RdvListParams {
  final int? patientId;
  final int? doctorId;
  final String filter;
  const RdvListParams({this.patientId, this.doctorId, this.filter = 'all'});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RdvListParams &&
          runtimeType == other.runtimeType &&
          patientId == other.patientId &&
          doctorId == other.doctorId &&
          filter == other.filter;

  @override
  int get hashCode => patientId.hashCode ^ doctorId.hashCode ^ filter.hashCode;
}

class RdvList extends ConsumerWidget {
  final String filter;
  final bool showPatientRdv;
  final int? patientId;
  final int? doctorId;
  const RdvList({
    required this.filter,
    required this.showPatientRdv,
    this.patientId,
    this.doctorId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = RdvListParams(
      patientId: patientId,
      doctorId: doctorId, // doctorId du médecin connecté
      filter: filter,
    );
    final rdvsAsync = ref.watch(rdvListProvider(params));
    final user = ref.watch(authProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return rdvsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (rdvs) {
        for (final rdv in rdvs) {
          print('ALL RDV status: "${rdv.status}" patientId: ${rdv.patientId}');
        }
        final filtered = rdvs.where((rdv) {
          // Filtrage selon le rôle
          if (params.doctorId != null) {
            if (rdv.doctorId != params.doctorId) return false;
          }
          if (params.patientId != null) {
            if (rdv.patientId != params.patientId) return false;
          }
          return rdvMatchesTab(filter, rdv.status);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text('Aucun rendez-vous', style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final rdv = filtered[i];
            print('RDV status: "${rdv.status}"'); // <-- Ajoute ceci
            return RdvCard(
              rdv: rdv,
              user: user,
              onCancel: rdv.status == 'upcoming'
                  ? () {
                      // Appelle le service pour annuler
                    }
                  : null,
              onReschedule: rdv.status == 'upcoming'
                  ? () {
                      // Appelle le service pour reprogrammer
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}

bool rdvMatchesTab(String filter, String status) {
  switch (filter) {
    case 'upcoming':
      return status == 'pending' || status == 'upcoming';
    case 'completed':
      return status == 'completed';
    case 'cancelled':
      return status == 'cancelled';
    case 'no_show':
      return status == 'no_show' || status == 'doctor_no_show' || status == 'expired';
    case 'all':
    default:
      return true;
  }
}