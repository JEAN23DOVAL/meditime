import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/services/admin_service.dart';

final summaryStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await AdminService().getSummaryStats();
});

void someFunction(Ref ref) {
  // some code
  ref.invalidate(summaryStatsProvider);
  // some code
}