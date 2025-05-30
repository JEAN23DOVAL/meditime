import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/models/doctor_model.dart';
import 'package:meditime_frontend/services/doctor_services.dart';

final doctorDetailProvider = FutureProvider.family<Doctor, int>((ref, idUser) async {
  return DoctorService().fetchDoctorByIdUser(idUser);
});