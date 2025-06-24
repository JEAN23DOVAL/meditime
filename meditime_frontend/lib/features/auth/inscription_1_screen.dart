import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // pour PhotoPicker
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_assets.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/services/local_storage_service.dart';
import 'package:meditime_frontend/widgets/buttons/appBar.dart';
import 'package:meditime_frontend/widgets/buttons/buttons.dart';
import 'package:meditime_frontend/widgets/formulaires/custom_text_field.dart';
import 'package:meditime_frontend/widgets/formulaires/photo_picker.dart';
import 'package:meditime_frontend/widgets/formulaires/validators.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ajoute cet import
import 'package:meditime_frontend/services/auth_services.dart'; // Garde cet import

class SignupScreen extends ConsumerStatefulWidget { // <-- Change State en ConsumerStatefulWidget
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  final TextEditingController _confirmMotDePasseController = TextEditingController();

  PlatformFile? _selectedPhoto;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Gestion de la sélection d'image
  Future<void> _pickPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedPhoto = result.files.first;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
    });
  }

  @override
  void initState() {
    super.initState();
    // Supprimez l'appel à precacheImage ici
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Préchargez les images ici
    precacheImage(const AssetImage(AppAssets.loginIllustration), context);
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final authService = ref.read(authServiceProvider);
      await authService.register(
        nom: _nomController.text.trim(),
        email: _emailController.text.trim(),
        motDePasse: _motDePasseController.text,
        photoProfilFile: _selectedPhoto,
      );

      setState(() => _isLoading = false);

      final user = ref.read(authProvider);
      if (user != null) {
        await LocalStorageService.completeFirstLaunch();
        if (user.role == 'admin') {
          context.go(AppRoutes.adminDashboard);
        } else {
          context.go(AppRoutes.homeUser);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'inscription.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez corriger les erreurs.')),
      );
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    _confirmMotDePasseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Inscription',
        centerTitle: true,
        horizontalPadding: 20,
        backgroundColor: AppColors.backgroundLight,
        titleTextStyle: AppStyles.heading0.copyWith(color: AppColors.secondary),
        leading: BackButtonCircle(
          onPressed: () => context.go(AppRoutes.connexion),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction, // Validation en direct
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image d'illustration
                Image.asset(AppAssets.signUp, height: 200),

                CustomTextField(
                  controller: _nomController,
                  labelText: 'Nom',
                  keyboardType: TextInputType.name,
                  validator: Validators.validateName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _motDePasseController,
                  labelText: 'Mot de passe',
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmMotDePasseController,
                  labelText: 'Confirmer mot de passe',
                  obscureText: _obscureConfirmPassword,
                  validator: (val) => Validators.confirmPassword(val, _motDePasseController.text),
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                PhotoPicker(
                  file: _selectedPhoto,
                  onPickImage: _pickPhoto,
                  onRemoveImage: _removePhoto,
                ),
                const SizedBox(height: 32),

                BigButton(
                  onPressed: _isLoading ? null : _submit,
                  label: _isLoading ? 'Chargement...' : 'S\'inscrire',
                ),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}