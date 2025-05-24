import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/models/doctor_slot_model.dart';
import 'provider/creneau_provider.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/constants/app_constants.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/widgets/timeslot_creation_dialog.dart';
import 'package:meditime_frontend/widgets/buttons/buttons.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/widgets/timeslot_card.dart';

class DoctorTimeslotsPage extends ConsumerWidget {
  const DoctorTimeslotsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final int? doctorId = user?.doctorId;

    if (doctorId == null) {
      return const Scaffold(
        body: Center(child: Text('Aucun doctorId trouvé pour cet utilisateur')),
      );
    }

    final timeslotsAsync = ref.watch(activeDoctorTimeslotsProvider(doctorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes créneaux actifs'),
        centerTitle: true,
        leading: BackButtonCircle(
          onPressed: () => context.go(AppRoutes.homeUser),
        ),
      ),
      body: timeslotsAsync.when(
        data: (slots) => slots.isEmpty
            ? const Center(child: Text('Aucun créneau actif'))
            : ListView.builder(
                itemCount: slots.length,
                itemBuilder: (context, index) => TimeslotCard(
                  slot: slots[index],
                  onEdit: () async {
                    // Ouvre un dialog de modification (à implémenter)
                    final updatedSlot = await showDialog<DoctorSlot>(
                      context: context,
                      builder: (context) => TimeslotCreationDialog(
                        doctorId: slots[index].doctorId,
                        initialSlot: slots[index],
                      ),
                    );
                    if (updatedSlot != null) {
                      await ref.read(timeslotUpdateProvider.notifier).updateSlot(updatedSlot);
                      ref.refresh(activeDoctorTimeslotsProvider(slots[index].doctorId));
                    }
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supprimer ce créneau ?'),
                        content: const Text('Cette action est irréversible.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(timeslotUpdateProvider.notifier).deleteSlot(slots[index].id!);
                      ref.refresh(activeDoctorTimeslotsProvider(slots[index].doctorId));
                    }
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
      floatingActionButton: CustomFloatingButton(
        onPressed: () => _showTimeslotCreationDialog(context, doctorId),
        icon: Icons.add,
        backgroundColor: AppConstants.primaryColor,
        iconColor: Colors.white,
        tooltip: 'Ajouter un créneau',
      ),
    );
  }

  void _showTimeslotCreationDialog(BuildContext context, int doctorId) {
    showDialog(
      context: context,
      builder: (context) => TimeslotCreationDialog(doctorId: doctorId),
    );
  }
}