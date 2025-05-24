import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/models/user_model.dart'; // Ajoute cet import

class ProfileHeader extends StatelessWidget {
  final User? user; // Remplace AuthUser? par User?
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarProvider;
    final photo = user?.profilePhoto;

    if (photo != null && photo.startsWith('http')) {
      avatarProvider = NetworkImage(photo);
    } else {
      avatarProvider = const AssetImage('assets/images/avatar.png');
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: avatarProvider,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${user?.lastName ?? ''} ${user?.firstName ?? ''}',
          style: AppStyles.heading1.copyWith(color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        Text(
          user?.email ?? '',
          style: AppStyles.bodyText.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}