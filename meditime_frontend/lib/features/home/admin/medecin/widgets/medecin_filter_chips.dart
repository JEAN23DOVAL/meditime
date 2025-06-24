/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medecin_provider.dart';

class MedecinFilterChips extends ConsumerWidget {
  const MedecinFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(medecinFilterProvider);
    final filters = [
      {'label': 'Tous', 'value': ''},
      {'label': 'En attente', 'value': 'pending'},
      {'label': 'Acceptés', 'value': 'accepted'},
      {'label': 'Refusés', 'value': 'refused'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: filters.map((f) {
          return ChoiceChip(
            label: Text(f['label']!),
            selected: selected == f['value'],
            onSelected: (_) => ref.read(medecinFilterProvider.notifier).state = f['value']!,
          );
        }).toList(),
      ),
    );
  }
} */