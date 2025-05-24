import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/medecin_silver_delegate.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/confirmer_compte_form.dart';

class ConfirmerCompte extends ConsumerStatefulWidget {
  const ConfirmerCompte({Key? key}) : super(key: key);

  @override
  ConsumerState<ConfirmerCompte> createState() => _ConfirmerCompteState();
}

class _ConfirmerCompteState extends ConsumerState<ConfirmerCompte> {
  final GlobalKey<ConfirmerCompteFormState> _formKeyChild = GlobalKey<ConfirmerCompteFormState>();
  double _progress = 0.0;

  void _onProgressChanged(double progress) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _progress = progress);
    });
  }

  @override
  Widget build(BuildContext context) {
    final headerChild = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Text(
          "Compléter mon profil",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 8, color: Colors.black26)],
              ),
        ),
      ],
    );

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: MedecinSilverDelegate(
                  expandedHeight: 320,
                  imageAsset: 'assets/images/patientsilver1.jfif',
                  roundedContainerHeight: 30,
                  child: headerChild,
                  // Supprime le bouton retour du delegate !
                  onBack: null,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConfirmerCompteForm(
                    key: _formKeyChild,
                    onProgressChanged: _onProgressChanged,
                  ),
                ),
              ),
            ],
          ),
          // Bouton retour toujours visible
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF312783)),
                onPressed: () => context.go(AppRoutes.homeUser),
                tooltip: 'Retour',
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(_progress),
    );
  }

  Widget _buildBottomNavigation(double progress) {
    final Color barColor = Color.lerp(Colors.red, Colors.green, progress) ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            color: barColor,
            backgroundColor: barColor.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _formKeyChild.currentState?.submit(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF36A9E1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Terminer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}