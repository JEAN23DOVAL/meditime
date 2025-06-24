import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/admin/provider/admin_stats_provider.dart';
import 'package:meditime_frontend/features/home/admin/provider/summary_provider.dart';
import 'package:meditime_frontend/features/home/admin/stats/stats_params.dart';
import 'package:meditime_frontend/features/home/admin/widgets/admin_drawer.dart';
import 'package:meditime_frontend/features/home/admin/widgets/kpi_card.dart';
import 'package:meditime_frontend/features/home/admin/widgets/stats_chart_section.dart';
import 'package:meditime_frontend/features/home/admin/widgets/stats_filter_bar.dart';

// --- Providers globaux pour les filtres ---
final statsPeriodProvider = StateProvider<String>((ref) => 'day');
final statsNbProvider = StateProvider<int>((ref) => 30);
final statsCustomRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

class AdminStatsScreen extends ConsumerWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);
    final nb = ref.watch(statsNbProvider);
    final customRange = ref.watch(statsCustomRangeProvider);

    final params = StatsParams(
      period: period,
      nb: nb,
      start: customRange?.start.toIso8601String(),
      end: customRange?.end.toIso8601String(),
    );
    final statsAsync = ref.watch(adminStatsProvider(params));
    final summaryAsync = ref.watch(summaryStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        centerTitle: true,
      ),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            StatsFilterBar(
              period: period,
              nb: nb,
              customRange: customRange,
              onChanged: ({String? period, int? nb, DateTimeRange? customRange}) {
                if (period != null) ref.read(statsPeriodProvider.notifier).state = period;
                if (nb != null) ref.read(statsNbProvider.notifier).state = nb;
                if (customRange != null) ref.read(statsCustomRangeProvider.notifier).state = customRange;
              },
            ),
            Expanded(
              child: statsAsync.when(
                data: (stats) => summaryAsync.when(
                  data: (summary) => ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      KPICardSection(stats: stats, summary: summary),
                      const SizedBox(height: 24),
                      StatsChartSection(stats: stats, period: period),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erreur stats: $e')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur stats: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}