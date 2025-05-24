// lib/shared/widgets/photo_picker.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PhotoPicker extends StatelessWidget {
  final PlatformFile? file;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const PhotoPicker({
    super.key,
    required this.file,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo de profil (optionnel)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: onPickImage,
              child: const Text('Parcourir'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                file != null ? file!.name : 'Aucune image sélectionnée',
                style: TextStyle(
                  color: file != null ? Colors.green[700] : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (file != null && file!.bytes != null) ...[
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  file!.bytes!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: onRemoveImage,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}