import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/constants/app_constants.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/models/doctor_slot_model.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/provider/creneau_provider.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/widgets/date_time_picker_widget.dart';

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
  DateTime? startDateTime;
  DateTime? endDateTime;

  @override
  void initState() {
    super.initState();
    // Initialise les DateTime avec les valeurs du créneau initial si elles sont disponibles
    if (widget.initialSlot != null) {
      startDateTime = DateTime(
        int.parse(widget.initialSlot!.startDay.split('-')[0]),
        int.parse(widget.initialSlot!.startDay.split('-')[1]),
        int.parse(widget.initialSlot!.startDay.split('-')[2]),
        widget.initialSlot!.startHour,
        widget.initialSlot!.startMinute,
      );
      endDateTime = DateTime(
        int.parse(widget.initialSlot!.endDay.split('-')[0]),
        int.parse(widget.initialSlot!.endDay.split('-')[1]),
        int.parse(widget.initialSlot!.endDay.split('-')[2]),
        widget.initialSlot!.endHour,
        widget.initialSlot!.endMinute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialSlot != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDateTimeRow(
          'Début de la période',
          startDateTime,
          () => _showDateTimePicker(
            context,
            'Début de la période',
            startDateTime,
            (date) {
              setState(() {
                startDateTime = date;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildDateTimeRow(
          'Fin de la période',
          endDateTime,
          startDateTime == null ? null : () => _showDateTimePicker(
            context,
            'Fin de la période',
            endDateTime ?? startDateTime!,
            (date) {
              setState(() {
                endDateTime = date;
              });
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildActionButtons(
          context,
          ref,
          onValidate: () async {
            final slot = DoctorSlot(
              id: widget.initialSlot?.id,
              doctorId: widget.doctorId,
              startDay: DateFormat('yyyy-MM-dd').format(startDateTime!),
              startHour: startDateTime!.hour,
              startMinute: startDateTime!.minute,
              endDay: DateFormat('yyyy-MM-dd').format(endDateTime!),
              endHour: endDateTime!.hour,
              endMinute: endDateTime!.minute,
            );

            if (isEditing) {
              await ref.read(timeslotUpdateProvider.notifier).updateSlot(slot);
              ref.refresh(activeDoctorTimeslotsProvider(widget.doctorId));
              if (mounted) Navigator.of(context).pop(slot);
            } else {
              await ref.read(timeslotCreationProvider.notifier).createSlot(slot);
              ref.refresh(activeDoctorTimeslotsProvider(widget.doctorId));
              if (mounted) Navigator.of(context).pop(slot);
            }
          },
          validateLabel: isEditing ? 'Modifier' : 'Valider',
          isLoading: isEditing
              ? ref.watch(timeslotUpdateProvider).isLoading
              : ref.watch(timeslotCreationProvider).isLoading,
        ),
      ],
    );
  }
  
  Widget _buildDateTimeRow(String label, DateTime? dateTime, VoidCallback? onPressed) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onPressed,
              child: const Text('Sélectionner'),
            ),
            if (dateTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  DateFormat('EEEE d MMMM yyyy – HH:mm', 'fr_FR').format(dateTime),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
          ],
        ),
      ],
    );
  }
  
  // Dans la méthode _buildActionButtons :
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref, {
    required Future<void> Function() onValidate,
    String validateLabel = 'Valider',
    bool isLoading = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
                  if (startDateTime != null && endDateTime != null && endDateTime!.isAfter(startDateTime!)) {
                    return AppConstants.secondaryColor;
                  }
                  return AppConstants.disabledColor;
                },
              ),
            ),
            onPressed: (startDateTime != null && endDateTime != null && endDateTime!.isAfter(startDateTime!))
                ? () async {
                    await onValidate();
                  }
                : null,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(validateLabel, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
  
  void _showDateTimePicker(
    BuildContext context,
    String label,
    DateTime? initialDate,
    Function(DateTime) onDateSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DateTimePickerWidget(
        label: label,
        initialDate: initialDate,
        onDateSelected: onDateSelected,
      ),
    );
  }
}