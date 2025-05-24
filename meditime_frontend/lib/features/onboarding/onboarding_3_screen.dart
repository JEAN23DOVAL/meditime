import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/configs/app_assets.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/providers/onboarding_provider.dart';
import 'package:meditime_frontend/widgets/buttons/buttons.dart';

class Onboarding3Screen extends ConsumerStatefulWidget {
  const Onboarding3Screen({super.key});

  @override
  ConsumerState<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends ConsumerState<Onboarding3Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();

    // Initialise l'AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Définit les animations de fondu
    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7)),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0)),
    );

    // Démarre les animations
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingNotifier = ref.read(onboardingStepProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Illustration avec animation de fondu
                FadeTransition(
                  opacity: _imageOpacity,
                  child: Hero(
                    tag: 'onboarding-illustration-3',
                    child: Image.asset(
                      AppAssets.onboarding3Illustration,
                      height: constraints.maxHeight * 0.3,
                      semanticLabel: 'Illustration de rappel de rendez-vous',
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Texte principal avec animation de fondu
                FadeTransition(
                  opacity: _textOpacity,
                  child: Text(
                    'Recevez des rappels pour ne jamais manquer un rendez-vous !',
                    textAlign: TextAlign.center,
                    style: AppStyles.heading3.copyWith(color: AppColors.textDark),
                  ),
                ),
                const Spacer(),

                // Indicateur de progression
                FadeTransition(
                  opacity: _buttonOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == 2 ? 12 : 8, // Indique que c'est la 3e étape
                        height: index == 2 ? 12 : 8,
                        decoration: BoxDecoration(
                          color: index == 2 ? AppColors.primary : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton "Commencer" avec animation de fondu
                FadeTransition(
                  opacity: _buttonOpacity,
                  child: 
                    BigButton(
                      onPressed: () {
                        onboardingNotifier.next();
                      },
                      label: 'Commencer',
                    ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }
}