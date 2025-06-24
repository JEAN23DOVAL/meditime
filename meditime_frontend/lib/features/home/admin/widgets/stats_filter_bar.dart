import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/services/admin_stats_service.dart';
import 'package:meditime_frontend/features/home/admin/stats/admin_stats_screen.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';

class StatsFilterBar extends ConsumerWidget {
  final String period;
  final int nb;
  final DateTimeRange? customRange;
  final void Function({String? period, int? nb, DateTimeRange? customRange}) onChanged;

  const StatsFilterBar({
    super.key,
    required this.period,
    required this.nb,
    required this.customRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = {
      'period': period,
      'nb': nb,
      if (customRange != null) ...{
        'start': customRange!.start.toIso8601String(),
        'end': customRange!.end.toIso8601String(),
      }
    };
    final service = AdminStatsService();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              DropdownButton<String>(
                value: period,
                items: const [
                  DropdownMenuItem(value: 'day', child: Text('Jour')),
                  DropdownMenuItem(value: 'week', child: Text('Semaine')),
                  DropdownMenuItem(value: 'month', child: Text('Mois')),
                ],
                onChanged: (v) => onChanged(period: v),
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: nb,
                items: const [
                  DropdownMenuItem(value: 7, child: Text('7')),
                  DropdownMenuItem(value: 14, child: Text('14')),
                  DropdownMenuItem(value: 30, child: Text('30')),
                  DropdownMenuItem(value: 90, child: Text('90')),
                ],
                onChanged: (v) => onChanged(nb: v),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: SizedBox(
                  width: 120,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      customRange == null
                          ? 'Plage personnalisée'
                          : '${customRange!.start.day}/${customRange!.start.month} - ${customRange!.end.day}/${customRange!.end.month}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2022),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) onChanged(customRange: picked);
                },
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Exporter (CSV)',
                onPressed: () async {
                  try {
                    final bytes = await service.exportStatsCsv(params);
                    await FileSaver.instance.saveFile(
                      name: 'stats.csv',
                      bytes: Uint8List.fromList(bytes),
                      ext: 'csv',
                      mimeType: MimeType.csv,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export CSV réussi')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur export CSV : $e')),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'Exporter (PDF)',
                onPressed: () async {
                  try {
                    final bytes = await service.exportStatsPdf(params);
                    await FileSaver.instance.saveFile(
                      name: 'stats.pdf',
                      bytes: Uint8List.fromList(bytes),
                      ext: 'pdf',
                      mimeType: MimeType.pdf,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export PDF réussi')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur export PDF : $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}