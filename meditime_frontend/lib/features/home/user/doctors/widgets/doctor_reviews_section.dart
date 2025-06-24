import 'package:flutter/material.dart';
import 'package:meditime_frontend/models/doctor_reviews_model.dart';
import 'package:meditime_frontend/services/doctor_reviews_service.dart';

class DoctorReviewsSection extends StatelessWidget {
  final int doctorId;
  const DoctorReviewsSection({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DoctorReview>>(
      future: DoctorReviewService().fetchReviewsByDoctor(doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Erreur lors du chargement des avis');
        }
        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const Text('Aucun avis pour ce médecin.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Avis des patients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final review = reviews[i];
                  final cardWidth = MediaQuery.of(context).size.width * 0.85;
                  bool isLong = (review.comment ?? '').length > 80;
                  bool expanded = false;

                  return StatefulBuilder(
                    builder: (context, setState) => Container(
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: review.patient?.profilePhoto != null && review.patient!.profilePhoto!.isNotEmpty
                                    ? NetworkImage(review.patient!.profilePhoto!)
                                    : null,
                                child: review.patient?.profilePhoto == null
                                    ? const Icon(Icons.person, size: 18, color: Colors.white)
                                    : null,
                                backgroundColor: Colors.blueGrey[200],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${review.patient?.firstName ?? ''} ${review.patient?.lastName ?? ''}'.trim(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (idx) => Icon(
                                    Icons.star,
                                    color: idx < review.rating ? Colors.amber : Colors.white24,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.comment ?? '',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  maxLines: expanded ? null : 2,
                                  overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                ),
                                if (isLong && !expanded)
                                  GestureDetector(
                                    onTap: () => setState(() => expanded = true),
                                    child: const Text(
                                      'Voir plus',
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${review.createdAt.day.toString().padLeft(2, '0')}/${review.createdAt.month.toString().padLeft(2, '0')}/${review.createdAt.year}',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}