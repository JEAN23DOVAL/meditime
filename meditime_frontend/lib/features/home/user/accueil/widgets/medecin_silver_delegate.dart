import 'package:flutter/material.dart';

class MedecinSilverDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final String imageAsset;
  final double roundedContainerHeight;
  final VoidCallback? onBack;
  final Widget? child; // Pour ajouter du contenu personnalisé sur l'image (ex: avatar, titre...)

  MedecinSilverDelegate({
    required this.expandedHeight,
    required this.imageAsset,
    this.roundedContainerHeight = 30,
    this.onBack,
    this.child,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double top = expandedHeight - shrinkOffset - roundedContainerHeight;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image de fond
        Positioned.fill(
          child: Image.asset(
            imageAsset,
            fit: BoxFit.cover,
          ),
        ),
        // Overlay sombre pour lisibilité
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.25),
          ),
        ),
        // Bouton retour
        /* Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF312783)),
              onPressed: onBack ?? () => context.go(AppRoutes.homeUser),
              tooltip: 'Retour',
            ),
          ),
        ), */
        // Contenu personnalisé (ex: avatar, titre, etc.)
        if (child != null)
          Positioned(
            left: 0,
            right: 0,
            top: top * 0.5,
            child: child!,
          ),
        // Container arrondi en bas
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: roundedContainerHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 16;

  @override
  bool shouldRebuild(covariant MedecinSilverDelegate old) {
    return expandedHeight != old.expandedHeight ||
        imageAsset != old.imageAsset ||
        roundedContainerHeight != old.roundedContainerHeight ||
        child != old.child;
  }
}