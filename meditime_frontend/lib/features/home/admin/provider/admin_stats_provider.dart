import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/admin/stats/stats_params.dart';
import 'package:meditime_frontend/services/admin_stats_service.dart';

final adminStatsServiceProvider = Provider((ref) => AdminStatsService());

final adminStatsProvider = FutureProvider.family<Map<String, dynamic>, StatsParams>((ref, params) async {
  final service = ref.read(adminStatsServiceProvider);
  return await service.fetchStats(
    period: params.period,
    nb: params.nb,
    start: params.start,
    end: params.end,
  );
});