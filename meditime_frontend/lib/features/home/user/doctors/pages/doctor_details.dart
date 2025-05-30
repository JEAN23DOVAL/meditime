import 'dart:ui';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:meditime_frontend/features/home/user/doctors/pages/providers/doctor_detail_provider.dart';
  import 'package:meditime_frontend/features/home/user/rdv/pages/provider/creneau_provider.dart';
  import 'package:meditime_frontend/features/home/user/rdv/pages/models/doctor_slot_model.dart';
import 'package:meditime_frontend/features/home/user/rdv/widgets/rdv_bottom_sheet_content.dart';

  class DoctorDetailPages extends ConsumerWidget {
    final int idUser;
    const DoctorDetailPages({super.key, required this.idUser});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final doctorAsync = ref.watch(doctorDetailProvider(idUser));
      return doctorAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
        data: (doctor) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Image de fond, plus visible
              if (doctor.user?.profilePhoto != null && doctor.user!.profilePhoto!.isNotEmpty)
                Opacity(
                  opacity: 0.55, // Plus visible mais pas trop
                  child: Image.network(
                    doctor.user!.profilePhoto!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              else
                Container(color: Colors.blueGrey[200]),
              // Effet glassmorphism
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),
              // Bouton retour
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Retour',
                  ),
                ),
              ),
              // Contenu principal
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom + certification (vers la gauche)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Dr. ${(doctor.user?.firstName ?? '').trim()} ${(doctor.user?.lastName ?? '').trim()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                        shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                                      ),
                                    ),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8), // petit espace si tu veux
                                        child: Icon(Icons.verified, color: Colors.lightBlueAccent, size: 28),
                                      ),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Description
                        if (doctor.description != null && doctor.description!.isNotEmpty)
                          _DoctorDescription(description: doctor.description!),
                        // Section stats
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Rating
                              Column(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 28),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctor.note.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text("Note", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              // Patients examinés
                              Column(
                                children: [
                                  const Icon(Icons.people, color: Colors.white, size: 26),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctor.patientsExamined?.toString() ?? '—',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text("Patients", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              // Années d'expérience
                              Column(
                                children: [
                                  const Icon(Icons.work, color: Colors.white, size: 26),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctor.experienceYears?.toString() ?? '—',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text("Expérience", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              // Prix par heure
                              Column(
                                children: [
                                  const Icon(Icons.attach_money, color: Colors.greenAccent, size: 26),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctor.pricePerHour != null ? "${doctor.pricePerHour} FCFA" : '—',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text("Prix/h", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 18),
                        // Section créneaux disponibles
                        Text(
                          "Créneaux disponibles",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ref.watch(activeDoctorTimeslotsProvider(doctor.id)).when(
                          data: (slots) {
                            if (slots.isEmpty) {
                              return const Center(
                                child: Text(
                                  "Aucun créneau disponible pour ce médecin.",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: slots.map((slot) => 
                                      Container(
                                        width: 260,
                                        margin: const EdgeInsets.only(right: 16),
                                        child: Card(
                                          color: Colors.white.withOpacity(0.15),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Du : ${_formatDate(slot.startDay)} à ${_formatHour(slot.startHour, slot.startMinute)}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "Au : ${_formatDate(slot.endDay)} à ${_formatHour(slot.endHour, slot.endMinute)}",
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ).toList(),
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: Colors.red))),
                        ),
                        
                        const SizedBox(height: 10),
                        // Section actions
                        Row(
                          children: [
                            // Prendre RDV à gauche (large)
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
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
                                        child: RdvBottomSheetContent(selectedDoctor: doctor),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.calendar_today, color: Colors.white),
                                label: const Text("Prendre RDV"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Noter à droite (icône étoile)
                            ElevatedButton(
                              onPressed: () {
                                // TODO: ouvrir le dialog de notation
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Icon(Icons.star, color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Remplace la section description par ce widget :
  class _DoctorDescription extends StatefulWidget {
    final String description;
    const _DoctorDescription({required this.description});

    @override
    State<_DoctorDescription> createState() => _DoctorDescriptionState();
  }

  class _DoctorDescriptionState extends State<_DoctorDescription> {
    bool expanded = false;

    @override
    Widget build(BuildContext context) {
      final isLong = widget.description.length > 100 || '\n'.allMatches(widget.description).length > 2;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              maxLines: expanded ? null : 3,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (isLong)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => expanded = !expanded),
                  child: Text(
                    expanded ? 'Masquer' : 'Voir plus',
                    style: const TextStyle(color: Colors.lightBlueAccent),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  class SlotPicker extends StatefulWidget {
  final List<DoctorSlot> slots;
  const SlotPicker({super.key, required this.slots});

  @override
  State<SlotPicker> createState() => _SlotPickerState();
}

class _SlotPickerState extends State<SlotPicker> {
  late DoctorSlot selectedSlot;
  late DateTime selectedDay;
  late int selectedHour;
  late int selectedMinute;

  List<DateTime> availableDays = [];
  List<int> availableHours = [];
  List<int> availableMinutes = [];

  @override
  void initState() {
    super.initState();
    selectedMinute = 0; // Initial fallback before any calculation
    selectedSlot = widget.slots.first;
    _initFromSlot(selectedSlot);
  }

  void _initFromSlot(DoctorSlot slot) {
    final start = DateTime.parse(slot.startDay)
        .add(Duration(hours: slot.startHour, minutes: slot.startMinute));
    final end = DateTime.parse(slot.endDay)
        .add(Duration(hours: slot.endHour, minutes: slot.endMinute));

    // Days list
    availableDays = [];
    DateTime day = DateTime(start.year, start.month, start.day);
    while (!day.isAfter(DateTime(end.year, end.month, end.day))) {
      availableDays.add(day);
      day = day.add(const Duration(days: 1));
    }
    selectedDay = availableDays.first;

    // Hours list
    _updateAvailableHours();
    selectedHour = availableHours.first;

    // Minutes list
    _updateAvailableMinutes();
    // Fallback if empty
    selectedMinute = availableMinutes.isNotEmpty ? availableMinutes.first : 0;
  }

  void _updateAvailableHours() {
    final slot = selectedSlot;
    availableHours = [];
    String dayKey = _formatDate(selectedDay);
    bool isStart = dayKey == slot.startDay;
    bool isEnd = dayKey == slot.endDay;

    int startH = isStart ? slot.startHour : 0;
    int endH = isEnd ? slot.endHour : 23;

    for (int h = startH; h <= endH; h++) {
      // Pour chaque heure, vérifie si au moins un créneau de 1h est possible
      int minMinute = 0;
      int maxMinute = 59;
      if (isStart && h == slot.startHour) minMinute = slot.startMinute;
      if (isEnd && h == slot.endHour) maxMinute = slot.endMinute;

      for (int m = minMinute; m <= maxMinute; m += 5) {
        final startDateTime = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, h, m);
        final endDateTime = startDateTime.add(const Duration(hours: 1));
        final slotEnd = DateTime.parse(slot.endDay).add(Duration(hours: slot.endHour, minutes: slot.endMinute));
        if (!endDateTime.isAfter(slotEnd)) {
          availableHours.add(h);
          break; // On ajoute l'heure si au moins un créneau de 1h est possible
        }
      }
    }
  }

  void _updateAvailableHoursAndMinutes() {
    _updateAvailableHours();
    if (!availableHours.contains(selectedHour)) {
      selectedHour = availableHours.first;
    }
    _updateAvailableMinutes();
  }

  void _updateAvailableMinutes() {
    final slot = selectedSlot;
    String dayKey = _formatDate(selectedDay);
    bool isStart = dayKey == slot.startDay && selectedHour == slot.startHour;
    bool isEnd = dayKey == slot.endDay && selectedHour == slot.endHour;

    int minM = isStart ? slot.startMinute : 0;
    int maxM = isEnd ? slot.endMinute : 59;

    availableMinutes = [];
    for (int m = minM; m <= maxM; m += 5) {
      final startDateTime = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, selectedHour, m);
      final endDateTime = startDateTime.add(const Duration(hours: 1));
      final slotEnd = DateTime.parse(slot.endDay).add(Duration(hours: slot.endHour, minutes: slot.endMinute));
      if (!endDateTime.isAfter(slotEnd)) {
        availableMinutes.add(m);
      }
    }

    if (!availableMinutes.contains(selectedMinute)) {
      selectedMinute = availableMinutes.isNotEmpty ? availableMinutes.first : 0;
    }
  }

  String _formatDate(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.slots.length > 1)
          DropdownButton<DoctorSlot>(
            value: selectedSlot,
            items: widget.slots
                .map((slot) => DropdownMenuItem(
                      value: slot,
                      child: Text(
                        "Du ${slot.startDay} ${slot.startHour}h${slot.startMinute.toString().padLeft(2, '0')} "
                        "au ${slot.endDay} ${slot.endHour}h${slot.endMinute.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
            onChanged: (slot) {
              setState(() {
                if (slot == null) return;
                selectedSlot = slot;
                _initFromSlot(selectedSlot);
              });
            },
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Picker Jour
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Jour", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 80,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      diameterRatio: 2.2,
                      perspective: 0.003,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedDay = availableDays[index];
                          _updateAvailableHoursAndMinutes();
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: availableDays.length,
                        builder: (context, index) {
                          final d = availableDays[index];
                          return Center(
                            child: Text(
                              "${d.day}/${d.month}/${d.year}",
                              style: TextStyle(
                                color: selectedDay == d ? Colors.blueAccent : Colors.white,
                                fontWeight: selectedDay == d ? FontWeight.bold : FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                          );
                        },
                      ),
                      controller: FixedExtentScrollController(
                        initialItem: availableDays.indexOf(selectedDay),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Picker Heure
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Heure", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 80,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      diameterRatio: 2.2,
                      perspective: 0.003,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedHour = availableHours[index];
                          _updateAvailableMinutes();
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: availableHours.length,
                        builder: (context, index) {
                          final h = availableHours[index];
                          return Center(
                            child: Text(
                              "${h.toString().padLeft(2, '0')}h",
                              style: TextStyle(
                                color: selectedHour == h ? Colors.blueAccent : Colors.white,
                                fontWeight: selectedHour == h ? FontWeight.bold : FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                          );
                        },
                      ),
                      controller: FixedExtentScrollController(
                        initialItem: availableHours.indexOf(selectedHour),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Picker Minute
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Minute", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 80,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      diameterRatio: 2.2,
                      perspective: 0.003,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedMinute = availableMinutes[index];
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: availableMinutes.length,
                        builder: (context, index) {
                          final m = availableMinutes[index];
                          return Center(
                            child: Text(
                              m.toString().padLeft(2, '0'),
                              style: TextStyle(
                                color: selectedMinute == m ? Colors.blueAccent : Colors.white,
                                fontWeight: selectedMinute == m ? FontWeight.bold : FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                          );
                        },
                      ),
                      controller: FixedExtentScrollController(
                        initialItem: availableMinutes.indexOf(selectedMinute),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}


  String _formatDate(String date) {
    // date attendu au format 'yyyy-MM-dd'
    try {
      final d = DateTime.parse(date);
      return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
    } catch (_) {
      return date;
    }
  }

  String _formatHour(int hour, int minute) {
    return "${hour.toString().padLeft(2, '0')}h${minute.toString().padLeft(2, '0')}";
  }