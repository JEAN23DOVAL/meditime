import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/models/doctor_slot_model.dart';

class TimeslotFormWidget2 extends StatefulWidget {
  final int doctorId;
  final DoctorSlot initialSlot;

  const TimeslotFormWidget2({
    required this.doctorId,
    required this.initialSlot,
    Key? key,
  }) : super(key: key);

  @override
  State<TimeslotFormWidget2> createState() => _TimeslotFormWidget2State();
}

class _TimeslotFormWidget2State extends State<TimeslotFormWidget2> {
  late DateTime selectedDay;
  late int selectedHour;
  late int selectedMinute;

  List<DateTime> availableDays = [];
  List<int> availableHours = [];
  List<int> availableMinutes = [];

  @override
  void initState() {
    super.initState();
    final slot = widget.initialSlot;

    // Génère la liste des jours du créneau
    final start = DateTime.parse(slot.startDay)
        .add(Duration(hours: slot.startHour, minutes: slot.startMinute));
    final end = DateTime.parse(slot.endDay)
        .add(Duration(hours: slot.endHour, minutes: slot.endMinute));

    availableDays = [];
    DateTime day = DateTime(start.year, start.month, start.day);
    while (!day.isAfter(DateTime(end.year, end.month, end.day))) {
      availableDays.add(day);
      day = day.add(const Duration(days: 1));
    }

    selectedDay = availableDays.first;
    _updateAvailableHoursAndMinutes();

    // Initialise l'heure et la minute sur la première valeur valide
    selectedHour = availableHours.first;
    selectedMinute = availableMinutes.first;
  }

  void _updateAvailableHoursAndMinutes() {
    final slot = widget.initialSlot;
    final start = DateTime.parse(slot.startDay)
        .add(Duration(hours: slot.startHour, minutes: slot.startMinute));
    final end = DateTime.parse(slot.endDay)
        .add(Duration(hours: slot.endHour, minutes: slot.endMinute));

    // Heures valides pour le jour sélectionné
    availableHours = [];
    if (DateFormat('yyyy-MM-dd').format(selectedDay) == slot.startDay &&
        DateFormat('yyyy-MM-dd').format(selectedDay) == slot.endDay) {
      // Un seul jour
      for (int h = slot.startHour; h <= slot.endHour; h++) {
        availableHours.add(h);
      }
    } else if (DateFormat('yyyy-MM-dd').format(selectedDay) == slot.startDay) {
      // Premier jour du créneau
      for (int h = slot.startHour; h <= 23; h++) {
        availableHours.add(h);
      }
    } else if (DateFormat('yyyy-MM-dd').format(selectedDay) == slot.endDay) {
      // Dernier jour du créneau
      for (int h = 0; h <= slot.endHour; h++) {
        availableHours.add(h);
      }
    } else {
      // Jours intermédiaires
      for (int h = 0; h <= 23; h++) {
        availableHours.add(h);
      }
    }

    // Corrige l'heure sélectionnée si elle n'est plus valide
    if (!availableHours.contains(selectedHour)) {
      selectedHour = availableHours.first;
    }

    // Minutes valides pour l'heure sélectionnée
    _updateAvailableMinutes();
  }

  void _updateAvailableMinutes() {
    final slot = widget.initialSlot;
    final isStartDay = DateFormat('yyyy-MM-dd').format(selectedDay) == slot.startDay;
    final isEndDay = DateFormat('yyyy-MM-dd').format(selectedDay) == slot.endDay;

    int minMinute = 0;
    int maxMinute = 59;

    if (isStartDay && selectedHour == slot.startHour) {
      minMinute = slot.startMinute;
    }
    if (isEndDay && selectedHour == slot.endHour) {
      maxMinute = slot.endMinute;
    }

    availableMinutes = [];
    for (int m = minMinute; m <= maxMinute; m += 5) {
      availableMinutes.add(m);
    }

    if (!availableMinutes.contains(selectedMinute)) {
      selectedMinute = availableMinutes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Choisir un créneau'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Picker Jour
          Row(
            children: [
              const Text('Jour :'),
              const SizedBox(width: 8),
              DropdownButton<DateTime>(
                value: selectedDay,
                items: availableDays
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(DateFormat('EEEE d MMMM', 'fr_FR').format(d)),
                        ))
                    .toList(),
                onChanged: (d) {
                  setState(() {
                    selectedDay = d!;
                    _updateAvailableHoursAndMinutes();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Picker Heure
          Row(
            children: [
              const Text('Heure :'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: selectedHour,
                items: availableHours
                    .map((h) => DropdownMenuItem(
                          value: h,
                          child: Text(h.toString().padLeft(2, '0') + 'h'),
                        ))
                    .toList(),
                onChanged: (h) {
                  setState(() {
                    selectedHour = h!;
                    _updateAvailableMinutes();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Picker Minute
          Row(
            children: [
              const Text('Minute :'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: selectedMinute,
                items: availableMinutes
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.toString().padLeft(2, '0')),
                        ))
                    .toList(),
                onChanged: (m) {
                  setState(() {
                    selectedMinute = m!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            // Ici tu peux envoyer la réservation avec selectedDay, selectedHour, selectedMinute
            Navigator.pop(context, DateTime(
              selectedDay.year,
              selectedDay.month,
              selectedDay.day,
              selectedHour,
              selectedMinute,
            ));
          },
          child: const Text('Réserver'),
        ),
      ],
    );
  }
}