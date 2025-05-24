import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/models/user_model.dart'; // <-- Corrige l'import
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';

class HeaderSection extends ConsumerWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = ref.watch(authProvider); // <-- Remplace AuthUser? par User?

    final String photoUrl = (user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty)
        ? user.profilePhoto!
        : 'assets/images/avatar.png';

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 25,
        right: 25,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Infos utilisateur
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user?.lastName ?? ''} ${user?.firstName ?? ''}',
                style: AppStyles.heading1.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 4),
              Text(
                'Bon retour sur Meditime',
                style: AppStyles.bodyText.copyWith(color: AppColors.textLight.withOpacity(0.7)),
              ),
            ],
          ),
          // Avatar
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
              radius: 28,
              backgroundImage: photoUrl.startsWith('http')
                  ? NetworkImage(photoUrl)
                  : AssetImage(photoUrl) as ImageProvider,
              backgroundColor: AppColors.backgroundLight,
            ),
          ),
        ],
      ),
    );
  }
}