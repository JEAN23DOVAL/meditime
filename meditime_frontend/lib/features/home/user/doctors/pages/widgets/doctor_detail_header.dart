import 'package:flutter/material.dart';
import 'package:meditime_frontend/models/doctor_model.dart';

class DoctorDetailHeader extends StatelessWidget {
  final Doctor doctor;
  const DoctorDetailHeader({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('Dr. ${doctor.user?.firstName ?? ''} ${doctor.user?.lastName ?? ''}'),
        background: doctor.user?.profilePhoto != null
            ? Image.network(doctor.user!.profilePhoto!, fit: BoxFit.cover)
            : Container(color: Colors.grey[300]),
      ),
    );
  }
}