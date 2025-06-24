import 'package:flutter/material.dart';

class ReviewDialog extends StatefulWidget {
  final void Function(int rating, String comment) onSubmit;
  const ReviewDialog({super.key, required this.onSubmit});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int rating = 0;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Laisser un avis'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => IconButton(
              icon: Icon(
                Icons.star,
                color: i < rating ? Colors.amber : Colors.grey,
              ),
              onPressed: () => setState(() => rating = i + 1),
            )),
          ),
          TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Votre commentaire'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: rating > 0
              ? () {
                  widget.onSubmit(rating, controller.text.trim());
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}