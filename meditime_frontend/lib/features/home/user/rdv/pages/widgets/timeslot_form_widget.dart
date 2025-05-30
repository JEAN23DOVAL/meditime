import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/models/doctor_slot_model.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/provider/creneau_provider.dart';

class TimeslotFormWidget extends ConsumerStatefulWidget {
  final int doctorId;
  final DoctorSlot? initialSlot; // <-- Ajoute ce champ

  const TimeslotFormWidget({
    required this.doctorId,
    this.initialSlot, // <-- Ajoute ce champ
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<TimeslotFormWidget> createState() => _TimeslotFormWidgetState();
}

class _TimeslotFormWidgetState extends ConsumerState<TimeslotFormWidget> {
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSlot != null) {
      final slot = widget.initialSlot!;
      startDate = DateTime.parse(slot.startDay);
      startTime = TimeOfDay(hour: slot.startHour, minute: slot.startMinute);
      endDate = DateTime.parse(slot.endDay);
      endTime = TimeOfDay(hour: slot.endHour, minute: slot.endMinute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            "Créer un créneau horaire",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // 1. Jour de début
          _HorizontalDatePicker(
            label: "Jour de début",
            selectedDate: startDate,
            onDateSelected: (date) {
              setState(() {
                startDate = date;
                // Reset heure de début si plus valide
                if (startTime != null && startTime!.hour < (date.isAtSameMomentAs(DateTime.now()) ? DateTime.now().hour : 6)) {
                  startTime = null;
                }
                // Reset fin si plus valide
                if (endDate != null && endDate!.isBefore(date)) {
                  endDate = null;
                  endTime = null;
                }
              });
            },
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          ),
          const SizedBox(height: 16),

          // 2. Heure de début
          _HorizontalTimePicker(
            label: "Heure de début",
            selectedTime: startTime,
            onTimeSelected: (time) {
              setState(() {
                startTime = time;
                // Reset heure de fin si plus valide
                if (endDate != null && endDate == startDate && endTime != null && endTime!.hour <= time.hour) {
                  endTime = null;
                }
              });
            },
            selectedDate: startDate,
          ),
          const SizedBox(height: 16),

          // 3. Jour de fin
          _HorizontalDatePicker(
            label: "Jour de fin",
            selectedDate: endDate,
            onDateSelected: (date) {
              setState(() {
                endDate = date;
                // Reset heure de fin si plus valide
                if (endTime != null && endDate == startDate && startTime != null && endTime!.hour <= startTime!.hour) {
                  endTime = null;
                }
              });
            },
            firstDate: startDate ?? DateTime.now(),
            lastDate: (startDate ?? DateTime.now()).add(const Duration(days: 7)),
          ),
          const SizedBox(height: 16),

          // 4. Heure de fin
          _HorizontalTimePicker(
            label: "Heure de fin",
            selectedTime: endTime,
            onTimeSelected: (time) => setState(() => endTime = time),
            selectedDate: endDate,
            compareDate: startDate,
            minTime: startTime,
            isEndPicker: true,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: (startDate != null && startTime != null && endDate != null && endTime != null && !isLoading)
                      ? () async {
                          setState(() => isLoading = true);
                          final slot = DoctorSlot(
                            id: widget.initialSlot?.id,
                            doctorId: widget.doctorId,
                            startDay: DateFormat('yyyy-MM-dd').format(startDate!),
                            startHour: startTime!.hour,
                            startMinute: startTime!.minute,
                            endDay: DateFormat('yyyy-MM-dd').format(endDate!),
                            endHour: endTime!.hour,
                            endMinute: endTime!.minute,
                            status: 'active',
                          );
                          try {
                            await ref.read(timeslotCreationProvider.notifier).createSlot(slot);
                            // Invalide le provider pour rafraîchir la liste
                            ref.invalidate(activeDoctorTimeslotsProvider(widget.doctorId));
                            if (mounted) {
                              Navigator.of(context).pop(true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Créneau créé avec succès !')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur lors de la création du créneau : $e')),
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Valider'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- PICKERS DESIGN ---

class _HorizontalDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final DateTime firstDate;
  final DateTime lastDate;

  const _HorizontalDatePicker({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final days = <DateTime>[];
    for (var d = firstDate;
        !d.isAfter(lastDate);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 5),
            itemBuilder: (context, i) {
              final d = days[i];
              final isSelected = selectedDate != null &&
                  d.year == selectedDate!.year &&
                  d.month == selectedDate!.month &&
                  d.day == selectedDate!.day;
              final isToday = DateTime.now().day == d.day &&
                  DateTime.now().month == d.month &&
                  DateTime.now().year == d.year;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onDateSelected(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[700]!,
                      // width: isSelected ? 2.5 : 1.5,
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
                          margin: const EdgeInsets.only(bottom: 1),
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
                          toBeginningOfSentenceCase(DateFormat.EEEE('fr_FR').format(d))!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      Text(
                        "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.grey[700],
                          fontSize: 11,
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
  }
}

class _HorizontalTimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final void Function(TimeOfDay) onTimeSelected;
  final DateTime? selectedDate;
  final DateTime? compareDate;
  final TimeOfDay? minTime; // Pour l'heure de début ou de fin
  final bool isEndPicker;

  const _HorizontalTimePicker({
    required this.label,
    required this.selectedTime,
    required this.onTimeSelected,
    this.selectedDate,
    this.compareDate,
    this.minTime,
    this.isEndPicker = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<TimeOfDay> times = [];

    // Pour l'heure de début
    if (!isEndPicker) {
      int startHour = 6;
      if (selectedDate != null &&
          selectedDate!.year == now.year &&
          selectedDate!.month == now.month &&
          selectedDate!.day == now.day) {
        // Si c'est aujourd'hui, commence à l'heure actuelle arrondie à l'heure inférieure
        startHour = now.hour;
      }
      for (int h = startHour; h <= 22; h++) {
        times.add(TimeOfDay(hour: h, minute: 0));
      }
    } else {
      // Pour l'heure de fin
      int startHour = 6;
      if (selectedDate != null && compareDate != null && selectedDate!.isAtSameMomentAs(compareDate!)) {
        // Même jour : commence à heure de début + 1
        if (minTime != null) {
          startHour = minTime!.hour + 1;
        }
      }
      for (int h = startHour; h <= 23; h++) {
        times.add(TimeOfDay(hour: h, minute: 0));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: times.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final t = times[i];
              final isSelected = selectedTime != null &&
                  t.hour == selectedTime!.hour &&
                  t.minute == selectedTime!.minute;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onTimeSelected(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
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
                  child: Text(
                    "${t.hour.toString().padLeft(2, '0')}:00",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}