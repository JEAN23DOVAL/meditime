import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';

class DoctorFiltersRow extends StatelessWidget {
  final ValueChanged<String> onFilterSelected;
  const DoctorFiltersRow({super.key, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'Spécialité', 'icon': Icons.filter_list},
      {'label': 'Localisation', 'icon': Icons.location_on},
      {'label': 'Disponibilité', 'icon': Icons.schedule},
      {'label': 'Autre Filtre', 'icon': Icons.star},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: () => onFilterSelected(filter['label'] as String),
                icon: Icon(filter['icon'] as IconData, color: Colors.white),
                label: Text(filter['label'] as String),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}