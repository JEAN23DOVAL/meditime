import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/models/doctor_slot_model.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/provider/creneau_provider.dart';
import 'package:meditime_frontend/models/doctor_model.dart';
import 'package:meditime_frontend/models/rdv_model.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:intl/intl.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';
import 'package:meditime_frontend/widgets/payment_webview.dart';

class RdvBottomSheetContent extends ConsumerStatefulWidget {
  final Doctor? selectedDoctor;
  final Rdv? initialRdv;

  const RdvBottomSheetContent({super.key, this.selectedDoctor, this.initialRdv});

  @override
  ConsumerState<RdvBottomSheetContent> createState() => _RdvBottomSheetContentState();
}

class _RdvBottomSheetContentState extends ConsumerState<RdvBottomSheetContent> {
  Doctor? selectedDoctor;
  DateTime? selectedTimeslot;
  String? motif;
  late String selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialRdv != null) {
      selectedDoctor = widget.selectedDoctor;
      selectedTimeslot = widget.initialRdv!.date;
      motif = widget.initialRdv!.motif;
      selectedDate = DateFormat('yyyy-MM-dd').format(widget.initialRdv!.date);
    } else {
      selectedDoctor = widget.selectedDoctor;
      selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    Widget timeslotSection;
    if (selectedDoctor != null) {
      final doctorId = selectedDoctor!.id;
      final params = AvailableSlotsParams(doctorId: doctorId, date: selectedDate);
      final availableSlotsAsync = ref.watch(availableSlotsProvider(params));

      timeslotSection = availableSlotsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('Erreur lors du chargement des créneaux', style: TextStyle(color: Colors.red)),
        ),
        data: (slots) {
          if (slots.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "Aucun créneau disponible pour ce médecin.",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choisissez un créneau",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: slots.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final isSelected = selectedTimeslot == slot.start;
                    final isToday = DateTime.now().day == slot.start.day &&
                        DateTime.now().month == slot.start.month &&
                        DateTime.now().year == slot.start.year;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: slot.isTaken
                          ? null
                          : () => setState(() => selectedTimeslot = slot.start),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : slot.isTaken
                                  ? Colors.grey[200]
                                  : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : slot.isTaken
                                    ? Colors.grey
                                    : Colors.grey[300]!,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isToday)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Aujourd'hui",
                                  style: TextStyle(fontSize: 11, color: Colors.deepOrange),
                                ),
                              )
                            else
                              Text(
                                toBeginningOfSentenceCase(DateFormat.EEEE('fr_FR').format(slot.start))!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : slot.isTaken
                                          ? Colors.grey
                                          : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            Text(
                              "${slot.start.day.toString().padLeft(2, '0')}/${slot.start.month.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white70
                                    : slot.isTaken
                                        ? Colors.grey
                                        : Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${slot.start.hour.toString().padLeft(2, '0')}:${slot.start.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : slot.isTaken
                                        ? Colors.grey
                                        : AppColors.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    } else {
      timeslotSection = const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Le contenu scrollable
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 24 + MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const Text(
                        "Prendre un rendez-vous",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // --- Zone Médecin ---
                      if (selectedDoctor == null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.person_search),
                            label: const Text("Choisir un médecin"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              final doctor = await context.push('/doctors/nearby');
                              if (doctor != null && doctor is Doctor) {
                                setState(() => selectedDoctor = doctor);
                              }
                            },
                          ),
                        )
                      else
                        Card(
                          color: Colors.blue[50],
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: selectedDoctor!.user?.profilePhoto != null
                                  ? NetworkImage(selectedDoctor!.user!.profilePhoto!)
                                  : null,
                              child: selectedDoctor!.user?.profilePhoto == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              'Dr. ${(selectedDoctor!.user?.firstName ?? '').trim()} ${(selectedDoctor!.user?.lastName ?? '').trim()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                                  tooltip: "Changer",
                                  onPressed: () async {
                                    final doctor = await Navigator.of(context, rootNavigator: true).pushNamed(
                                      '/doctors/nearby',
                                      arguments: {
                                        'patientCity': user?.city,
                                        'excludeDoctorId': user?.role == 'doctor' ? user?.doctorId : null,
                                      },
                                    );
                                    if (doctor != null && doctor is Doctor) {
                                      setState(() => selectedDoctor = doctor);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  tooltip: "Effacer",
                                  onPressed: () => setState(() => selectedDoctor = null),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // --- Picker créneau ---
                      timeslotSection,
                      const SizedBox(height: 16),

                      // --- Motif ---
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Motif du rendez-vous'),
                        onChanged: (v) => motif = v,
                      ),
                      const SizedBox(height: 16),

                      // Affichage du montant minimum à payer
                      if (selectedDoctor != null && selectedDoctor!.pricePerHour != null)
                        Builder(
                          builder: (context) {
                            final int price = selectedDoctor!.pricePerHour!;
                            final int platformFee = calculatePlatformFee(price);
                            return Card(
                              color: Colors.green[50],
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: const Icon(Icons.payments, color: Colors.green),
                                title: Text(
                                  'Montant minimum à payer',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${platformFee.toString()} XAF de commission\n'
                                  'Prix total : ${price.toString()} XAF',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 80), // Pour laisser la place au bouton
                    ],
                  ),
                ),
              ),
              // Bouton fixé en bas
              SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (selectedDoctor != null && selectedTimeslot != null && motif != null && motif!.isNotEmpty)
                        ? () async {
                            final user = ref.read(authProvider);
                            if (user == null) return;

                            // Affiche le loader
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );

                            try {
                              final rdv = Rdv(
                                id: widget.initialRdv?.id ?? 0,
                                patientId: user.idUser,
                                doctorId: selectedDoctor!.idUser,
                                specialty: selectedDoctor!.specialite ?? '',
                                date: selectedTimeslot!,
                                motif: motif,
                                durationMinutes: 60,
                                status: widget.initialRdv != null ? 'pending' : 'upcoming',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                patient: null,
                                doctor: null,
                              );
                              final rdvService = ref.read(rdvServiceProvider);

                              if (widget.initialRdv != null) {
                                await rdvService.updateRdv(rdv);
                                Navigator.of(context, rootNavigator: true).pop(); // Ferme le loader
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Rendez-vous reprogrammé avec succès !')),
                                );
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  if (mounted) Navigator.of(context, rootNavigator: true).pop();
                                });
                              } else {
                                final result = await rdvService.createRdv(rdv);
                                final paymentUrl = result['paymentUrl'];
                                final transactionId = result['transactionId'];

                                Navigator.of(context, rootNavigator: true).pop(); // Ferme le loader
                                await Future.delayed(const Duration(milliseconds: 100));

                                // Ouvre la WebView directement depuis le bottom sheet
                                if (context.mounted) {
                                  await Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                      builder: (_) => PaymentWebView(
                                        url: paymentUrl,
                                        transactionId: transactionId,
                                        onPaymentSuccess: () {
                                          // Ferme le bottom sheet et rafraîchis les providers
                                          if (context.mounted) {
                                            Navigator.of(context).pop(true); // Ferme le bottom sheet
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              Navigator.of(context, rootNavigator: true).pop();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur lors de la réservation : $e')),
                                );
                              }
                            }
                          }
                        : null,
                    child: const Text('Réserver le RDV'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int calculatePlatformFee(int price) {
    if (price <= 10000) return 1000;
    if (price <= 20000) return (price * 0.10).round();
    if (price <= 50000) return (price * 0.08).round();
    return (price * 0.05).round();
  }
}

class _AvailableSlot {
  final DoctorSlot slot;
  final DateTime dateTime;
  _AvailableSlot(this.slot, this.dateTime);
}