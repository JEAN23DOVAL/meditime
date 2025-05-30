import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import '../services/creneau_services.dart';
import '../models/doctor_slot_model.dart';
import '../models/available_slot_model.dart';

final timeslotServiceProvider = Provider<TimeslotService>((ref) => TimeslotService());

// Provider pour les créneaux actifs d'un médecin
final activeDoctorTimeslotsProvider = FutureProvider.family<List<DoctorSlot>, int>((ref, doctorId) async {
  final service = ref.read(timeslotServiceProvider);
  return service.getActiveSlotsByDoctor(doctorId);
});

final timeslotCreationProvider = StateNotifierProvider<TimeslotCreationNotifier, AsyncValue<void>>(
  (ref) => TimeslotCreationNotifier(ref.read(timeslotServiceProvider)),
);

class TimeslotCreationNotifier extends StateNotifier<AsyncValue<void>> {
  final TimeslotService _service;
  TimeslotCreationNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> createSlot(DoctorSlot slot) async {
    try {
      state = const AsyncValue.loading();
      await _service.createSlot(slot);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final timeslotUpdateProvider = StateNotifierProvider<TimeslotUpdateNotifier, AsyncValue<void>>(
  (ref) => TimeslotUpdateNotifier(ref.read(timeslotServiceProvider)),
);

class TimeslotUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final TimeslotService _service;
  TimeslotUpdateNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> updateSlot(DoctorSlot slot) async {
    try {
      state = const AsyncValue.loading();
      await _service.updateSlot(slot);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteSlot(int slotId) async {
    try {
      state = const AsyncValue.loading();
      await _service.deleteSlot(slotId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class AvailableSlotsParams {
  final int doctorId;
  final String date;
  const AvailableSlotsParams({required this.doctorId, required this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableSlotsParams &&
          runtimeType == other.runtimeType &&
          doctorId == other.doctorId &&
          date == other.date;

  @override
  int get hashCode => doctorId.hashCode ^ date.hashCode;
}

final availableSlotsProvider = FutureProvider.family<List<AvailableSlot>, AvailableSlotsParams>((ref, params) async {
  final service = ref.read(timeslotServiceProvider);
  final token = await ref.read(authProvider.notifier).getToken();
  if (token == null) throw Exception('Token utilisateur manquant');
  return service.getAvailableSlots(
    doctorId: params.doctorId,
    date: params.date,
    token: token,
  );
});