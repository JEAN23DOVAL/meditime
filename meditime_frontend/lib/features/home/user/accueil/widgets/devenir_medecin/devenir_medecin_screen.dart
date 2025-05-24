import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/devenir_medecin/devenir_medecin_form.dart';
import 'package:meditime_frontend/features/home/user/accueil/widgets/medecin_silver_delegate.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/services/doctor_application_service.dart';

class DevenirMedecinScreen extends StatefulWidget {
  const DevenirMedecinScreen({super.key});

  @override
  State<DevenirMedecinScreen> createState() => _DevenirMedecinScreenState();
}

class _DevenirMedecinScreenState extends State<DevenirMedecinScreen> {
  double _progress = 0.0;
  final GlobalKey<DevenirMedecinFormState> _formKey = GlobalKey<DevenirMedecinFormState>();

  void _onProgressChanged(double progress) {
    setState(() => _progress = progress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: MedecinSilverDelegate(
                  expandedHeight: 360,
                  imageAsset: 'assets/images/headersilver1.jfif',
                  roundedContainerHeight: 30,
                ),
              ),
              SliverToBoxAdapter(
                child: DevenirMedecinForm(
                  key: _formKey,
                  onProgressChanged: _onProgressChanged,
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
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    final color = _progress < 0.33
        ? Colors.red
        : _progress < 0.66
            ? Colors.orange
            : Colors.green;
    return Consumer(
      builder: (context, ref, _) {
        final user = ref.watch(authProvider);
        final formState = _formKey.currentState;
        final hasPending = formState?.hasPendingApplication ?? false;
        final isLoading = formState?.isLoading ?? false;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: _progress,
                color: color,
                backgroundColor: color.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (isLoading || hasPending)
                      ? null
                      : () async {
                          if (user == null) return;
                          if (hasPending) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vous avez déjà une demande en attente de validation.')),
                            );
                            return;
                          }
                          if (user.isVerified == false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez compléter votre profil avant de faire une demande.')),
                            );
                            return;
                          }
                          if (_formKey.currentState?.validateForm() ?? false) {
                            try {
                              final data = _formKey.currentState!.getFormData();
                              final service = DoctorApplicationService();
                              await service.submitDoctorApplication(
                                idUser: user.idUser,
                                specialite: data['specialite'],
                                diplomes: data['diplomes'],
                                numeroInscription: data['numeroInscription'],
                                hopital: data['hopital'],
                                adresseConsultation: data['adresseConsultation'],
                                cniFrontPath: (data['cniFront'] as File?)?.path,
                                cniBackPath: (data['cniBack'] as File?)?.path,
                                certificationPath: (data['certification'] as File?)?.path,
                                cvPdfPath: (data['cvPdf'] as File?)?.path,
                                casierJudiciairePath: (data['casierJudiciaire'] as File?)?.path,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Demande envoyée avec succès.')),
                                );
                                context.go(AppRoutes.homeUser);
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur lors de l\'envoi : $e')),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Envoyer pour vérification',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}