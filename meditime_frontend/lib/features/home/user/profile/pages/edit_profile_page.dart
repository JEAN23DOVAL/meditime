import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_header.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController lastNameController;
  late TextEditingController firstNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController cityController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    lastNameController = TextEditingController(text: user?.lastName ?? '');
    firstNameController = TextEditingController(text: user?.firstName ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
    cityController = TextEditingController(text: user?.city ?? '');
  }

  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 24),
            _buildTextField('Nom', lastNameController),
            const SizedBox(height: 16),
            _buildTextField('Prénom', firstNameController),
            const SizedBox(height: 16),
            _buildTextField('Email', emailController, enabled: false),
            const SizedBox(height: 16),
            _buildTextField('Téléphone', phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField('Ville', cityController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Ajoute la logique de sauvegarde plus tard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Modification enregistrée (simulation)')),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: AppStyles.bodyText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}