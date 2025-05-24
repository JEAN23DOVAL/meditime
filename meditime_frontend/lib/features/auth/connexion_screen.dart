import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_assets.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/services/auth_services.dart'; // Ajoute cet import
import 'package:meditime_frontend/widgets/buttons/appBar.dart';
import 'package:meditime_frontend/widgets/buttons/buttons.dart';
import 'package:meditime_frontend/widgets/formulaires/custom_text_field.dart';
import 'package:meditime_frontend/widgets/formulaires/validators.dart';
import 'package:meditime_frontend/configs/app_routes.dart';

class ConnexionScreen extends ConsumerStatefulWidget {
  const ConnexionScreen({super.key});

  @override
  ConsumerState<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends ConsumerState<ConnexionScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
   bool _isLoading = false;
  bool _obscureText = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage(AppAssets.loginIllustration), context);
    precacheImage(AssetImage(AppAssets.googleLogo), context);
    precacheImage(AssetImage(AppAssets.appleLogo), context);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final authService = ref.read(authServiceProvider);
      final email = emailController.text.trim();
      final password = passwordController.text;
      final user = await authService.login(email, password);
      setState(() => _isLoading = false);

      if (user != null) {
        // Recharge l'utilisateur depuis le token pour être sûr
        final token = await ref.read(authProvider.notifier).getToken();
        if (token != null) {
          await ref.read(authProvider.notifier).reloadFromToken(token);
        }
        final currentUser = ref.read(authProvider);
        if (currentUser != null) {
          if (currentUser.role == 'admin') {
            context.go(AppRoutes.adminDashboard);
          } else {
            context.go(AppRoutes.homeUser);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la connexion, veuillez vérifier vos informations.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Connexion',
        centerTitle: true,
        horizontalPadding: 20,
        backgroundColor: AppColors.backgroundLight,
        titleTextStyle: AppStyles.heading0.copyWith(color: AppColors.secondary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, // validation en direct
            child: Column(
              children: [
                Image.asset(
                  AppAssets.loginIllustration,
                  height: 250,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: passwordController,
                  labelText: 'Mot de passe',
                  obscureText: _obscureText,
                  validator: Validators.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: _togglePasswordVisibility,
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => context.go(AppRoutes.forgotPass),
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.inscription),
                      child: const Text("S'inscrire ?"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                BigButton(
                    onPressed: _isLoading ? null : _login,
                    label: 'Se Connecter'
                ),
                
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {/* Action Google */},
                      icon: Image.asset(AppAssets.googleLogo, height: 20),
                      label: const Text('Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {/* Action Apple */},
                      icon: Image.asset(AppAssets.appleLogo, height: 20),
                      label: const Text('Apple'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}