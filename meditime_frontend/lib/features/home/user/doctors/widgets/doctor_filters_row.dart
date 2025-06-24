import 'package:flutter/material.dart';

class DoctorFiltersRow extends StatefulWidget {
  final ValueChanged<bool?> onAvailableChanged;
  final ValueChanged<RangeValues> onPriceRangeChanged;
  final ValueChanged<String?> onGenderChanged;
  final bool initialAvailable;
  final RangeValues initialPriceRange;
  final String? initialGender;
  final void Function(void Function())? onResetFilters;

  const DoctorFiltersRow({
    super.key,
    required this.onAvailableChanged,
    required this.onPriceRangeChanged,
    required this.onGenderChanged,
    this.initialAvailable = false,
    this.initialPriceRange = const RangeValues(0, 100000),
    this.initialGender,
    this.onResetFilters,
  });

  @override
  State<DoctorFiltersRow> createState() => _DoctorFiltersRowState();
}

class _DoctorFiltersRowState extends State<DoctorFiltersRow> {
  late bool available;
  late RangeValues priceRange;
  String? gender;

  @override
  void initState() {
    super.initState();
    available = widget.initialAvailable;
    priceRange = widget.initialPriceRange;
    gender = widget.initialGender;
    widget.onResetFilters?.call(resetFilters);
  }

  void resetFilters() {
    setState(() {
      available = false;
      priceRange = const RangeValues(0, 100000);
      gender = null;
    });
    widget.onAvailableChanged(null);
    widget.onPriceRangeChanged(const RangeValues(0, 100000));
    widget.onGenderChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final genders = ['Homme', 'Femme'];
    final theme = Theme.of(context);

    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        children: [
          // Disponibilité
          FilterChip(
            label: Row(
              children: [
                Icon(Icons.event_available, color: available ? Colors.green : Colors.grey, size: 18),
                const SizedBox(width: 4),
                const Text('Disponible'),
              ],
            ),
            selected: available,
            selectedColor: Colors.green.withOpacity(0.18),
            checkmarkColor: Colors.green,
            onSelected: (v) {
              setState(() => available = v);
              widget.onAvailableChanged(v ? true : null);
            },
            backgroundColor: Colors.grey.withOpacity(0.10),
            labelStyle: TextStyle(color: available ? Colors.green : Colors.black),
            shape: StadiumBorder(
              side: BorderSide(color: available ? Colors.green : Colors.grey.shade300, width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          // Prix min/max
          FilterChip(
            label: Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.blueAccent, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Prix: ${priceRange.start.round()} - ${priceRange.end.round()}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            selected: priceRange.start > 0 || priceRange.end < 100000,
            selectedColor: Colors.blue.withOpacity(0.18),
            onSelected: (_) async {
              // Affiche un slider dans un bottom sheet pour choisir la plage de prix
              final result = await showModalBottomSheet<RangeValues>(
                context: context,
                builder: (ctx) {
                  RangeValues temp = priceRange;
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: StatefulBuilder(
                      builder: (context, setModalState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Choisir la plage de prix', style: TextStyle(fontWeight: FontWeight.bold)),
                            RangeSlider(
                              values: temp,
                              min: 0,
                              max: 100000,
                              divisions: 20,
                              labels: RangeLabels(
                                temp.start.round().toString(),
                                temp.end.round().toString(),
                              ),
                              onChanged: (values) {
                                setModalState(() => temp = values);
                              },
                            ),
                            Text(
                              'Prix sélectionné: ${temp.start.round()} - ${temp.end.round()}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, temp),
                              child: const Text('Valider'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, const RangeValues(0, 100000)),
                              child: const Text('Réinitialiser'),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
              if (result != null) {
                setState(() => priceRange = result);
                widget.onPriceRangeChanged(result);
              }
            },
            backgroundColor: Colors.grey.withOpacity(0.10),
            labelStyle: TextStyle(
              color: (priceRange.start > 0 || priceRange.end < 100000) ? Colors.blueAccent : Colors.black,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: (priceRange.start > 0 || priceRange.end < 100000) ? Colors.blueAccent : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Sexe
          ...genders.map((g) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Row(
                children: [
                  Icon(
                    g == 'Homme' ? Icons.male : Icons.female,
                    color: gender == g ? Colors.purple : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(g),
                ],
              ),
              selected: gender == g,
              selectedColor: Colors.purple.withOpacity(0.18),
              checkmarkColor: Colors.purple,
              onSelected: (v) {
                setState(() {
                  // Si déjà sélectionné, on désactive
                  if (gender == g) {
                    gender = null;
                    widget.onGenderChanged(null);
                  } else {
                    gender = g;
                    widget.onGenderChanged(g);
                  }
                });
              },
              backgroundColor: Colors.grey.withOpacity(0.10),
              labelStyle: TextStyle(color: gender == g ? Colors.purple : Colors.black),
              shape: StadiumBorder(
                side: BorderSide(color: gender == g ? Colors.purple : Colors.grey.shade300, width: 1.5),
              ),
            ),
          )),
        ],
      ),
    );
  }
}