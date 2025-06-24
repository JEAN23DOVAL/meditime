import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selected = 'fr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Langue'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSectionTitle(title: 'Choisir la langue'),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.blue),
            title: const Text('Français', style: AppStyles.bodyText),
            trailing: Radio<String>(
              value: 'fr',
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v!),
              activeColor: AppColors.primary,
            ),
            onTap: () => setState(() => _selected = 'fr'),
          ),
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.red),
            title: const Text('English', style: AppStyles.bodyText),
            trailing: Radio<String>(
              value: 'en',
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v!),
              activeColor: AppColors.primary,
            ),
            onTap: () => setState(() => _selected = 'en'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Valider', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                // TODO: Appliquer la langue à l'app
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_selected == 'fr'
                      ? 'Langue changée en français'
                      : 'Language switched to English')),
                );
                // Ajoute ici la logique pour changer la langue globalement
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
}