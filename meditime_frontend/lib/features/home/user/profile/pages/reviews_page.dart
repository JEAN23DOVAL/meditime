import 'package:flutter/material.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/profile/widgets/profile_section_title.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simule des avis reçus
    final reviews = [
      {
        'name': 'Jean Dupont',
        'date': '12/06/2025',
        'rating': 5,
        'comment': 'Très bon médecin, à l’écoute et professionnel.',
        'answered': true,
        'answer': 'Merci beaucoup pour votre retour !'
      },
      {
        'name': 'Marie Claire',
        'date': '10/06/2025',
        'rating': 4,
        'comment': 'Consultation rapide et efficace.',
        'answered': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avis reçus'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSectionTitle(title: 'Avis de vos patients'),
          const SizedBox(height: 16),
          ...reviews.map((review) => _buildReviewCard(context, review)).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Map review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.primary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    review['name'],
                    style: AppStyles.heading3.copyWith(color: AppColors.textDark),
                  ),
                ),
                Row(
                  children: List.generate(
                    review['rating'],
                    (i) => const Icon(Icons.star, color: Colors.amber, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review['comment'],
              style: AppStyles.bodyText,
            ),
            const SizedBox(height: 8),
            Text(
              review['date'],
              style: AppStyles.caption.copyWith(color: Colors.grey),
            ),
            if (review['answered'] == true) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.reply, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      review['answer'],
                      style: AppStyles.bodyText.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.reply, color: AppColors.primary),
                  label: const Text('Répondre', style: TextStyle(color: AppColors.primary)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => _ReplyDialog(
                        onSend: (text) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Réponse envoyée (simulation)')),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _ReplyDialog extends StatefulWidget {
  final void Function(String) onSend;
  const _ReplyDialog({required this.onSend});

  @override
  State<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<_ReplyDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Répondre à l\'avis'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Votre réponse...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.send, size: 18),
          label: const Text('Envoyer'),
          onPressed: () {
            widget.onSend(_controller.text);
          },
        ),
      ],
    );
  }
}