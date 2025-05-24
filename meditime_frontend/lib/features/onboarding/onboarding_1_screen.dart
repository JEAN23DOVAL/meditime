import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/configs/app_assets.dart';
import 'package:meditime_frontend/providers/onboarding_provider.dart';
import 'package:meditime_frontend/widgets/buttons/buttons.dart';

class Onboarding1Screen extends ConsumerStatefulWidget {
  const Onboarding1Screen({super.key});

  @override
  ConsumerState<Onboarding1Screen> createState() => _Onboarding1ScreenState();
}

class _Onboarding1ScreenState extends ConsumerState<Onboarding1Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _buttonsOpacity;

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

    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
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
                    tag: 'onboarding-illustration',
                    child: Image.asset(
                      AppAssets.onboarding1Illustration,
                      height: constraints.maxHeight * 0.3,
                      semanticLabel: 'Illustration de prise de rendez-vous',
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Texte principal avec animation de fondu
                FadeTransition(
                  opacity: _textOpacity,
                  child: Text(
                    'Prenez vos rendez-vous médicaux avec simplicité !',
                    textAlign: TextAlign.center,
                    style: AppStyles.heading3.copyWith(color: AppColors.textDark),
                  ),
                ),
                const Spacer(),

                // Indicateur de progression
                FadeTransition(
                  opacity: _buttonsOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == 0 ? 12 : 8,
                        height: index == 0 ? 12 : 8,
                        decoration: BoxDecoration(
                          color: index == 0 ? AppColors.primary : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Boutons avec animation de fondu
                FadeTransition(
                  opacity: _buttonsOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkipButton(
                        onPressed: () {
                          onboardingNotifier.skip();
                        },
                      ),
                      NextButton(
                        onPressed: () {
                          onboardingNotifier.next();
                        },
                      ),
                    ],
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