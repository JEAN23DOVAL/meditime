import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';

class RdvCard extends StatelessWidget {
  final String title;
  final String date;
  final String status;

  const RdvCard({
    required this.title,
    required this.date,
    required this.status,
    super.key,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'ongoing':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'ongoing':
        return Icons.timelapse;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.event_note;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return "Terminé";
      case 'ongoing':
        return "À venir";
      case 'cancelled':
        return "Annulé";
      default:
        return "Inconnu";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(status);
    final IconData statusIcon = _statusIcon(status);
    final String statusLabel = _statusLabel(status);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            // Icône dans un cercle coloré
            CircleAvatar(
              radius: 28,
              backgroundColor: statusColor.withOpacity(0.12),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 18),
            // Infos principales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.heading2.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: AppStyles.bodyText.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Badge de statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                statusLabel,
                style: AppStyles.bodyText.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}