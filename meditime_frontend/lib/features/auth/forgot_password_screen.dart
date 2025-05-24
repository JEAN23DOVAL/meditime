import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_assets.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/widgets/buttons/appBar.dart';
import 'package:meditime_frontend/widgets/buttons/buttons.dart';
import 'package:meditime_frontend/widgets/formulaires/custom_text_field.dart';
import 'package:meditime_frontend/widgets/formulaires/validators.dart';


class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isCodeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Simule envoi du code
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
        _isCodeSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un code de vérification a été envoyé à votre email.'),
        ),
      );
    }
  }

  void _submitCode() {
    if ((_codeController.text.trim().length == 6)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code vérifié avec succès.')),
      );
      context.go('/reset-password');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un code valide.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mot de passe oublié',
        centerTitle: true,
        horizontalPadding: 20,
        backgroundColor: AppColors.backgroundLight,
        titleTextStyle: AppStyles.heading1.copyWith(color: AppColors.secondary),
        leading: BackButtonCircle(
          onPressed: () => context.go(AppRoutes.connexion), // ou AppRoutes.welcome
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAssets.loginIllustration, height: 200),
                const SizedBox(height: 24),

                if (!_isCodeSent) ...[
                  Text(
                    'Entrez votre adresse email pour recevoir un code de vérification.',
                    style: AppStyles.heading3.copyWith(color: AppColors.textDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),

                  BigButton(
                    label: _isLoading ? 'Envoi...' : 'Envoyer',
                    onPressed: _isLoading ? null : () => _submitEmail(),
                  ),
                ] else ...[
                  const Text(
                    'Entrez le code à 6 chiffres reçu par email.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: _codeController,
                    labelText: 'Code de vérification',
                    keyboardType: TextInputType.number,
                    validator: (val) => Validators.validateCode(val),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),

                  BigButton(
                    label: 'Vérifier',
                    onPressed: _submitCode,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}