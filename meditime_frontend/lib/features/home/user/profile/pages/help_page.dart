import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'Comment prendre un rendez-vous ?',
        'answer': 'Allez dans la section "Rendez-vous", choisissez un médecin et suivez les instructions.'
      },
      {
        'question': 'Comment contacter l\'assistance ?',
        'answer': 'Utilisez le bouton "Contacter l\'assistance" ci-dessous ou envoyez un email à support@meditime.com.'
      },
      {
        'question': 'Comment modifier mes informations ?',
        'answer': 'Rendez-vous dans "Mon Profil" puis "Modifier le profil".'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSectionTitle(title: 'FAQ'),
          const SizedBox(height: 16),
          ...faqs.map((faq) => _buildFaqTile(faq)).toList(),
          const SizedBox(height: 32),
          const ProfileSectionTitle(title: 'Contact'),
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.primary),
            title: const Text('support@meditime.com', style: AppStyles.bodyText),
            subtitle: const Text('Email assistance'),
            onTap: () {
              // TODO: Ouvre le mailto ou copie l'email
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ouverture de l\'email...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: AppColors.primary),
            title: const Text('+237 6 99 99 99 99', style: AppStyles.bodyText),
            subtitle: const Text('Téléphone assistance'),
            onTap: () {
              // TODO: Ouvre le dialer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appel assistance...')),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.support_agent, color: Colors.white),
              label: const Text('Contacter l\'assistance', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                // TODO: Ouvre un chat ou un formulaire de contact
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact assistance à venir...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(Map faq) {
    return ExpansionTile(
      leading: const Icon(Icons.help_outline, color: AppColors.primary),
      title: Text(faq['question'], style: AppStyles.heading3.copyWith(fontSize: 16)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Text(faq['answer'], style: AppStyles.bodyText),
        ),
      ],
    );
  }
}