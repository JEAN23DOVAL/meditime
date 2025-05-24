import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_styles.dart';

class DoctorSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const DoctorSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un médecin...',
          hintStyle: AppStyles.bodyText.copyWith(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}