import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/models/doctor_model.dart';
import 'package:meditime_frontend/providers/doctor_provider.dart';

class BestSection extends ConsumerWidget {
  const BestSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(bestDoctorsProvider);

    return SizedBox(
      height: 250,
      child: doctorsAsync.when(
        data: (doctors) {
          if (doctors.isEmpty) {
            return const Center(child: Text('Aucun médecin trouvé'));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              final user = doctor.user;

              return _buildDoctorCard(
                doctor: doctor,
                name: user != null
                    ? 'Dr. ${(user.firstName ?? '').trim()} ${(user.lastName).trim()}'.trim()
                    : 'Dr. ${doctor.idUser}',
                specialty: doctor.specialite,
                rating: doctor.note > 0 ? doctor.note.toStringAsFixed(1) : '--',
                image: user?.profilePhoto,
                context: context,
              );
            },
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (e, _) {
          return Center(child: Text('Erreur: $e'));
        },
      ),
    );
  }

  Widget _buildDoctorCard({
    required Doctor doctor,
    required String name,
    required String specialty,
    required String rating,
    String? image,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('${AppRoutes.doctorDetail}/${doctor.idUser}');
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: image != null && image.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.grey[300],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.2),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      specialty,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}