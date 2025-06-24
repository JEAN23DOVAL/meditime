import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';
import 'rdv_card.dart';

class RdvListParams {
  final int? patientId;
  final int? doctorId;
  final String filter;
  final String? search;
  final String? sortBy;
  final String? order;

  const RdvListParams({
    this.patientId,
    this.doctorId,
    this.filter = 'all',
    this.search,
    this.sortBy,
    this.order,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RdvListParams &&
          runtimeType == other.runtimeType &&
          patientId == other.patientId &&
          doctorId == other.doctorId &&
          filter == other.filter &&
          search == other.search &&
          sortBy == other.sortBy &&
          order == other.order;

  @override
  int get hashCode =>
      patientId.hashCode ^
      doctorId.hashCode ^
      filter.hashCode ^
      (search?.hashCode ?? 0) ^
      (sortBy?.hashCode ?? 0) ^
      (order?.hashCode ?? 0);
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
        // Si une recherche est active, n'applique pas le filtre status côté front
        final bool isSearching = params.search != null && params.search!.isNotEmpty;
        final filtered = rdvs.where((rdv) {
          if (params.doctorId != null && rdv.doctorId != params.doctorId) return false;
          if (params.patientId != null && rdv.patientId != params.patientId) return false;
          // Si recherche, ne filtre pas par status côté front
          if (!isSearching) {
            return rdvMatchesTab(params.filter, rdv.status);
          }
          return true;
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
            return RdvCard(
              rdv: rdv,
              user: user,
              ref: ref,
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
      // Affiche tous les statuts d'absence dans "Non honoré"
      return status == 'no_show' || status == 'doctor_no_show' || status == 'expired' || status == 'both_no_show';
    case 'all':
    default:
      return true;
  }
}