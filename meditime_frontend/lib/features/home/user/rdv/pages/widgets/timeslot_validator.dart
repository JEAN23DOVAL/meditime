import 'package:meditime_frontend/features/home/user/rdv/pages/models/doctor_slot_model.dart';

class TimeslotValidator {
  static bool isValidRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return end.isAfter(start);
  }
  
  static String? validateDateRange(DateTime? start, DateTime? end) {
    if (start == null) return 'Date de début requise';
    if (end == null) return 'Date de fin requise';
    if (!end.isAfter(start)) return 'La date de fin doit être après le début';
    
    // Additional validation: check if start is not in the past
    final now = DateTime.now();
    if (start.isBefore(now.subtract(const Duration(minutes: 1)))) {
      return 'La date de début ne peut pas être dans le passé';
    }
    
    // Check maximum duration (e.g., 12 hours)
    final duration = end.difference(start);
    if (duration.inHours > 12) {
      return 'La durée ne peut pas dépasser 12 heures';
    }
    
    return null;
  }
  
  // Validate DoctorSlot before sending to backend
  static String? validateDoctorSlot(DoctorSlot slot) {
    // Check required fields
    if (slot.doctorId <= 0) return 'ID médecin invalide';
    if (slot.startHour < 0 || slot.startHour > 23) return 'Heure de début invalide';
    if (slot.startMinute < 0 || slot.startMinute > 59) return 'Minute de début invalide';
    if (slot.endHour < 0 || slot.endHour > 23) return 'Heure de fin invalide';
    if (slot.endMinute < 0 || slot.endMinute > 59) return 'Minute de fin invalide';
    
    // Validate date format (YYYY-MM-DD)
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(slot.startDay)) return 'Format de date de début invalide';
    if (!dateRegex.hasMatch(slot.endDay)) return 'Format de date de fin invalide';
    
    return null;
  }
}