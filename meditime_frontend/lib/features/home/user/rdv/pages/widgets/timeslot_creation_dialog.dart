import 'package:flutter/material.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/constants/app_constants.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/models/doctor_slot_model.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/widgets/timeslot_form_widget.dart';

class TimeslotCreationDialog extends StatelessWidget {
  final int doctorId;
  final DoctorSlot? initialSlot; // <-- Ajoute ce champ

  const TimeslotCreationDialog({
    Key? key,
    required this.doctorId,
    this.initialSlot, // <-- Ajoute ce champ
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(AppConstants.dialogPadding),
        child: TimeslotFormWidget(
          doctorId: doctorId,
          initialSlot: initialSlot, // <-- Passe-le au formulaire
        ),
      ),
    );
  }
}

