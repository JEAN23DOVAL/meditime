// ignore_for_file: unused_element

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meditime_frontend/widgets/formulaires/custom_text_field.dart';
import 'package:meditime_frontend/widgets/formulaires/validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditime_frontend/services/doctor_application_service.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/configs/app_routes.dart';

class DevenirMedecinForm extends ConsumerStatefulWidget {
  final void Function(double progress)? onProgressChanged;
  const DevenirMedecinForm({super.key, this.onProgressChanged});

  @override
  ConsumerState<DevenirMedecinForm> createState() => DevenirMedecinFormState();
}

class DevenirMedecinFormState extends ConsumerState<DevenirMedecinForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String? _specialite, _diplomes, _numeroInscription, _hopital, _adresseConsultation;
  File? _cniFront, _cniBack, _certification, _cvPdf, _casierJudiciaireFile;

  late final TextEditingController _specialiteController;
  late final TextEditingController _diplomesController;
  late final TextEditingController _numeroInscriptionController;
  late final TextEditingController _hopitalController;
  late final TextEditingController _adresseConsultationController;

  static const int _totalFields = 9;

  bool _hasPendingApplication = false;
  bool _isLoading = false;

  void _notifyProgress() {
    int count = 0;
    if (_specialite != null && _specialite!.isNotEmpty && Validators.validateName(_specialite) == null) count++;
    if (_diplomes != null && _diplomes!.isNotEmpty) count++;
    if (_numeroInscription != null && Validators.validateName(_numeroInscription) == null) count++;
    if (_hopital != null && _hopital!.isNotEmpty) count++;
    if (_adresseConsultation != null && _adresseConsultation!.isNotEmpty) count++;
    if (_cniFront != null && Validators.validateImageFile(_cniFront, label: 'CNI Recto') == null) count++;
    if (_cniBack != null && Validators.validateImageFile(_cniBack, label: 'CNI Verso') == null) count++;
    if (_certification != null) count++;
    if (_cvPdf != null && Validators.validatePdfFile(_cvPdf, label: 'CV', maxSizeMB: 5) == null) count++;
    if (_casierJudiciaireFile != null && Validators.validatePdfFile(_casierJudiciaireFile, label: 'Casier judiciaire', maxSizeMB: 5) == null) count++;
    widget.onProgressChanged?.call(count / _totalFields);
  }

  @override
  void initState() {
    super.initState();
    _specialiteController = TextEditingController();
    _diplomesController = TextEditingController();
    _numeroInscriptionController = TextEditingController();
    _hopitalController = TextEditingController();
    _adresseConsultationController = TextEditingController();
    _checkPendingApplication();
  }

  Future<void> _checkPendingApplication() async {
    final user = ref.read(authProvider);
    if (user == null) return;
    setState(() => _isLoading = true);
    final service = DoctorApplicationService();
    final lastApp = await service.getLastApplication(user.idUser);
    if (lastApp != null && lastApp['status'] == 'pending') {
      setState(() {
        _hasPendingApplication = true;
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _specialiteController.dispose();
    _diplomesController.dispose();
    _numeroInscriptionController.dispose();
    _hopitalController.dispose();
    _adresseConsultationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(authProvider);
    if (user == null) return;

    if (_hasPendingApplication) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous avez déjà une demande en attente de validation.')),
      );
      return;
    }

    // Vérifie si le profil est complété
    if (user.isVerified == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez compléter votre profil avant de faire une demande.')),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final service = DoctorApplicationService();
        await service.submitDoctorApplication(
          idUser: user.idUser,
          specialite: _specialiteController.text,
          diplomes: _diplomesController.text,
          numeroInscription: _numeroInscriptionController.text,
          hopital: _hopitalController.text,
          adresseConsultation: _adresseConsultationController.text,
          cniFrontPath: _cniFront?.path,
          cniBackPath: _cniBack?.path,
          certificationPath: _certification?.path,
          cvPdfPath: _cvPdf?.path,
          casierJudiciairePath: _casierJudiciaireFile?.path,
        );
        // Succès : retour à l'accueil
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
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  Map<String, dynamic> getFormData() {
    return {
      'specialite': _specialiteController.text,
      'diplomes': _diplomesController.text,
      'numeroInscription': _numeroInscriptionController.text,
      'hopital': _hopitalController.text,
      'adresseConsultation': _adresseConsultationController.text,
      'cniFront': _cniFront,
      'cniBack': _cniBack,
      'certification': _certification,
      'cvPdf': _cvPdf,
      'casierJudiciaire': _casierJudiciaireFile,
    };
  }

  bool get hasPendingApplication => _hasPendingApplication;
  bool get isLoading => _isLoading;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasPendingApplication) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info, color: Colors.orange, size: 48),
            SizedBox(height: 16),
            Text(
              'Votre demande est en cours de traitement.\nVeuillez attendre la réponse de l\'administrateur.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Informations professionnelles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _specialiteController,
              labelText: 'Spécialité médicale',
              onChanged: (v) {
                setState(() => _specialite = v);
                _notifyProgress();
              },
              validator: (v) => Validators.validateName(v),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _diplomesController,
              labelText: 'Diplômes',
              onChanged: (v) {
                setState(() => _diplomes = v);
                _notifyProgress();
              },
              validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _numeroInscriptionController,
              labelText: 'Numéro d\'inscription à l\'ordre',
              onChanged: (v) {
                setState(() => _numeroInscription = v);
                _notifyProgress();
              },
              validator: (v) => Validators.validateName(v),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _hopitalController,
              labelText: 'Hôpital/Clinique d\'exercice',
              onChanged: (v) {
                setState(() => _hopital = v);
                _notifyProgress();
              },
              validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _adresseConsultationController,
              labelText: 'Adresse du lieu de consultation',
              onChanged: (v) {
                setState(() => _adresseConsultation = v);
                _notifyProgress();
              },
              validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            CustomImagePickerField(
              label: 'CNI/Passport (Recto)',
              file: _cniFront,
              onPick: () async {
                final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
                if (img != null) setState(() => _cniFront = File(img.path));
                _notifyProgress();
              },
              errorText: Validators.validateImageFile(_cniFront, label: 'CNI Recto'),
            ),
            const SizedBox(height: 12),
            CustomImagePickerField(
              label: 'CNI/Passport (Verso)',
              file: _cniBack,
              onPick: () async {
                final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
                if (img != null) setState(() => _cniBack = File(img.path));
                _notifyProgress();
              },
              errorText: Validators.validateImageFile(_cniBack, label: 'CNI Verso'),
            ),
            const SizedBox(height: 12),
            CustomImagePickerField(
              label: 'Certification pour exercer',
              file: _certification,
              onPick: () async {
                final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
                if (img != null) setState(() => _certification = File(img.path));
                _notifyProgress();
              },
              errorText: Validators.validateImageFile(_certification, label: 'Certification'),
            ),
            const SizedBox(height: 12),
            CustomFilePickerField(
              label: 'CV (PDF)',
              file: _cvPdf,
              onPick: () async {
                final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                if (res?.files.first.path != null) setState(() => _cvPdf = File(res!.files.first.path!));
                _notifyProgress();
              },
              errorText: Validators.validatePdfFile(_cvPdf, label: 'CV', maxSizeMB: 5),
            ),
            const SizedBox(height: 12),
            CustomFilePickerField(
              label: 'Casier judiciaire (PDF)',
              file: _casierJudiciaireFile,
              onPick: () async {
                final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                if (res?.files.first.path != null) setState(() => _casierJudiciaireFile = File(res!.files.first.path!));
                _notifyProgress();
              },
              errorText: Validators.validatePdfFile(_casierJudiciaireFile, label: 'Casier judiciaire', maxSizeMB: 5),
            ),
          ],
        ),
      ),
    );
  }
}