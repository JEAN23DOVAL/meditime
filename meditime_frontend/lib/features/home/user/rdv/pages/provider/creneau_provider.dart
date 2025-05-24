import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/creneau_services.dart';
import '../models/doctor_slot_model.dart';

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