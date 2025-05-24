import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor_model.dart';
import '../services/doctor_services.dart';

final doctorServiceProvider = Provider((ref) => DoctorService());

final doctorNearbyProvider = FutureProvider<List<Doctor>>((ref) async {
  print('doctorNearbyProvider appelé');
  final service = ref.read(doctorServiceProvider);
  return await service.fetchDoctorsByProximity(ref);
});