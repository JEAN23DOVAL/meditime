import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';
import 'package:meditime_frontend/models/consutation_model.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simule des documents liés à des RDV
    final documents = [
      ConsultationFile(id: 1, fileUrl: 'https://example.com/ordonnance1.pdf', fileType: 'Ordonnance'),
      ConsultationFile(id: 2, fileUrl: 'https://example.com/analyse1.pdf', fileType: 'Analyse'),
      ConsultationFile(id: 3, fileUrl: 'https://example.com/compte_rendu1.pdf', fileType: 'Compte rendu'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes documents'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSectionTitle(title: 'Documents médicaux'),
          const SizedBox(height: 16),
          ...documents.map((doc) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(
                    doc.fileType == 'Ordonnance'
                        ? Icons.description
                        : doc.fileType == 'Analyse'
                            ? Icons.science
                            : Icons.insert_drive_file,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  title: Text(doc.fileType, style: AppStyles.bodyText),
                  subtitle: Text(doc.fileUrl, style: AppStyles.caption, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.download, color: AppColors.secondary),
                    onPressed: () {
                      // TODO: Télécharger ou ouvrir le document
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Téléchargement à venir...')),
                      );
                    },
                  ),
                  onTap: () {
                    // TODO: Ouvrir le document
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ouverture du document à venir...')),
                    );
                  },
                ),
              )),
        ],
      ),
    );
  }
}