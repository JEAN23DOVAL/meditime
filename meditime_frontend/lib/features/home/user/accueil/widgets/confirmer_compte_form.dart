import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/models/user_model.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/widgets/formulaires/custom_text_field.dart';
import 'package:meditime_frontend/widgets/formulaires/validators.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meditime_frontend/services/user_services.dart';
import 'package:meditime_frontend/providers/router_provider.dart';


class ConfirmerCompteForm extends ConsumerStatefulWidget {
  const ConfirmerCompteForm({
    super.key,
    this.onSaved,
    this.onProgressChanged,
  });

  final void Function(double progress)? onProgressChanged;
  final void Function()? onSaved;

  @override
  ConfirmerCompteFormState createState() => ConfirmerCompteFormState();
}

class ConfirmerCompteFormState extends ConsumerState<ConfirmerCompteForm> {
  final _birthDateController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _genderController = TextEditingController();
  // Contrôleurs pour chaque champ du modèle User (sauf rôle)
  final _lastNameController = TextEditingController();

  final _phoneController = TextEditingController();
  final _profilePhotoController = TextEditingController();
  PlatformFile? _selectedPhoto;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _profilePhotoController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    if (user != null) {
      _lastNameController.text = user.lastName;
      _firstNameController.text = user.firstName ?? '';
      _emailController.text = user.email;
      _profilePhotoController.text = user.profilePhoto ?? '';
      _birthDateController.text = user.birthDate != null
          ? "${user.birthDate!.day}/${user.birthDate!.month}/${user.birthDate!.year}"
          : '';
      _genderController.text = user.gender ?? '';
      _phoneController.text = user.phone ?? '';
      _cityController.text = user.city ?? '';

      if (user.profilePhoto != null && user.profilePhoto!.isNotEmpty) {
        // On ne peut pas pré-remplir PlatformFile, donc on affiche juste l'image
        _profilePhotoController.text = user.profilePhoto!;
      }
    }
      _notifyProgress();
  }

  void submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSaved?.call();
      final userService = UserService();
      try {
        final result = await userService.updateProfile(
          lastName: _lastNameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          email: _emailController.text.trim(),
          city: _cityController.text.trim(),
          phone: _phoneController.text.trim(),
          gender: _genderController.text.trim(),
          birthDate: _birthDateController.text.trim(),
          profilePhoto: _selectedPhoto,
        );
        if (result != null && result['user'] != null) {
          if (result['token'] != null) {
            await ref.read(authProvider.notifier).saveToken(result['token']);
          }
          ref.read(authProvider.notifier).updateUser(User.fromMap(result['user']));
          ref.read(routerProvider).go(AppRoutes.homeUser);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la mise à jour du profil.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  Future<void> _pickPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedPhoto = result.files.first;
        _profilePhotoController.text = ''; // On vide le champ texte si nouvelle photo
      });
      _notifyProgress();
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
      _profilePhotoController.text = '';
    });
    _notifyProgress();
  }

  void _notifyProgress() {
    int filled = 0;

    if (_lastNameController.text.trim().isNotEmpty && Validators.validateName(_lastNameController.text) == null) filled++;
    if (_firstNameController.text.trim().isNotEmpty && Validators.validateName(_firstNameController.text) == null) filled++;
    if (_birthDateController.text.trim().isNotEmpty) filled++;
    if (_genderController.text.trim().isNotEmpty) filled++;
    if (_emailController.text.trim().isNotEmpty && Validators.validateEmail(_emailController.text) == null) filled++;
    if (_phoneController.text.trim().isNotEmpty && Validators.validatePhone(_phoneController.text) == null) filled++;
    if (_cityController.text.trim().isNotEmpty) filled++;
    // Photo de profil : soit une photo sélectionnée, soit un lien http valide
    if (_selectedPhoto != null || (_profilePhotoController.text.trim().isNotEmpty && _profilePhotoController.text.startsWith('http'))) filled++;

    double progress = filled / 8;
    widget.onProgressChanged?.call(progress);
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
  final user = ref.read(authProvider); // Ajoute cette ligne

  return Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(
          title: "Informations personnelles",
          children: [
            CustomTextField(
              controller: _lastNameController,
              labelText: "Nom",
              validator: Validators.validateName,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _notifyProgress(),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _firstNameController,
              labelText: "Prénom",
              validator: Validators.validateName,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _notifyProgress(),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _birthDateController,
              labelText: "Date de naissance",
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  // Stocke la date au format ISO
                  _birthDateController.text = picked.toIso8601String().split('T').first; // "YYYY-MM-DD"
                  _notifyProgress();
                }
              },
              validator: (val) =>
                  val == null || val.isEmpty ? "Veuillez choisir une date" : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _genderController.text.isNotEmpty ? _genderController.text : null,
              decoration: const InputDecoration(
                labelText: "Genre",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Homme", child: Text("Homme")),
                DropdownMenuItem(value: "Femme", child: Text("Femme")),
              ],
              onChanged: (value) {
                _genderController.text = value ?? '';
                _notifyProgress();
              },
              validator: (val) =>
                  val == null || val.isEmpty ? "Veuillez renseigner le genre" : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: "Contact",
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: "Email",
              validator: Validators.validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _notifyProgress(),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _phoneController,
              labelText: "Téléphone",
              validator: Validators.validatePhone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _notifyProgress(),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _cityController,
              labelText: "Ville",
              validator: (val) =>
                  val == null || val.isEmpty ? "Veuillez renseigner la ville" : null,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _notifyProgress(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: "Profil",
          children: [
            Builder(
              builder: (context) {
                if (_selectedPhoto != null || _profilePhotoController.text.isNotEmpty) {
                  return Row(
                    key: const ValueKey('photo-row'),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _selectedPhoto != null
                            ? Image.memory(
                                _selectedPhoto!.bytes!,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              )
                            : (user != null && user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                                ? Image.network(
                                    user.profilePhoto!,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox.shrink()),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                      ),
                      if (_selectedPhoto != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _removePhoto,
                          tooltip: 'Supprimer la photo',
                        ),
                    ],
                  );
                } else {
                  return ElevatedButton.icon(
                    key: const ValueKey('photo-button'),
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Ajouter une photo'),
                  );
                }
              },
            ),
          ],
        ),
      ],
    ),
  );
}
}