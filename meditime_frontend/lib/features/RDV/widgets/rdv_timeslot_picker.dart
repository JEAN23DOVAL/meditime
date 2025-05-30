import 'package:flutter/material.dart';

class RdvTimeslotPicker extends StatelessWidget {
  final String? doctorId;
  final void Function(DateTime date) onTimeslotSelected;

  const RdvTimeslotPicker({
    super.key,
    required this.doctorId,
    required this.onTimeslotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Choisir un créneau horaire'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 60)),
        );
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 9, minute: 0),
          );
          if (time != null) {
            final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            onTimeslotSelected(dt);
          }
        }
      },
    );
  }
}