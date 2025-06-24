import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/services/admin_service.dart';
import 'package:meditime_frontend/models/admin_model.dart';

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

class AdminListParams {
  final String search;
  final String sortBy;
  final String order;
  final String adminRole;
  const AdminListParams({
    this.search = '',
    this.sortBy = 'createdAt',
    this.order = 'DESC',
    this.adminRole = 'all',
  });

  AdminListParams copyWith({
    String? search,
    String? sortBy,
    String? order,
    String? adminRole,
  }) {
    return AdminListParams(
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
      adminRole: adminRole ?? this.adminRole,
    );
  }
}

class AdminListNotifier extends StateNotifier<AsyncValue<List<AdminModel>>> {
  final AdminService service;
  AdminListParams params;

  AdminListNotifier(this.service, [AdminListParams? initial])
      : params = initial ?? const AdminListParams(),
        super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final admins = await service.getAllAdmins(
        search: params.search,
        sortBy: params.sortBy,
        order: params.order,
        adminRole: params.adminRole,
      );
      state = AsyncValue.data(admins);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateParams(AdminListParams newParams) {
    params = newParams;
    fetch();
  }
}

final adminListNotifierProvider = StateNotifierProvider<AdminListNotifier, AsyncValue<List<AdminModel>>>(
  (ref) => AdminListNotifier(ref.read(adminServiceProvider)),
);