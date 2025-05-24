import 'package:flutter_riverpod/flutter_riverpod.dart';

class Doctor {
  final String name;
  final String specialty;
  final String location;
  final String image;

  Doctor({
    required this.name,
    required this.specialty,
    required this.location,
    required this.image,
  });
}

// Liste simulée (remplace par un fetch API plus tard)
final doctorListProvider = Provider<List<Doctor>>((ref) => [
  Doctor(name: 'Dr. Jean Dupont', specialty: 'Cardiologue', location: 'Paris', image: 'assets/images/doctor.png'),
  Doctor(name: 'Dr. Alice Martin', specialty: 'Dermatologue', location: 'Lyon', image: 'assets/images/doctor.png'),
  // ... autres médecins
]);

final doctorSearchProvider = StateProvider<String>((ref) => '');
final doctorFilterProvider = StateProvider<String>((ref) => '');

final filteredDoctorsProvider = Provider<List<Doctor>>((ref) {
  final doctors = ref.watch(doctorListProvider);
  final search = ref.watch(doctorSearchProvider).toLowerCase();
  final filter = ref.watch(doctorFilterProvider);

  return doctors.where((doc) {
    final matchesSearch = doc.name.toLowerCase().contains(search) || doc.specialty.toLowerCase().contains(search);
    final matchesFilter = filter.isEmpty || doc.specialty == filter || doc.location == filter;
    return matchesSearch && matchesFilter;
  }).toList();
});