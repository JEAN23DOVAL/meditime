import 'package:flutter/material.dart';
import 'rdv_list.dart';

class RdvStatusTabs extends StatelessWidget {
  final bool showPatientRdv;
  final String filter;
  final int? patientId;
  final int? doctorId;
  const RdvStatusTabs({
    super.key,
    required this.showPatientRdv,
    required this.filter,
    this.patientId,
    this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return RdvList(
      filter: filter,
      showPatientRdv: showPatientRdv,
      patientId: patientId,
      doctorId: doctorId,
    );
  }
}