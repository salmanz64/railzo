import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/dashboard_stats.dart';
import '../../../data/repositories/dashboard_repository.dart';

part 'dashboard_view_model.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  late DashboardRepository _repo;

  @override
  AsyncValue<DashboardStats> build() {
    _repo = ref.watch(dashboardRepositoryProvider);
    _fetchDashboardStats();
    return const AsyncValue.loading();
  }

  Future<void> _fetchDashboardStats() async {
    final res = await _repo.getDashboardStats();

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (stats) {
        state = AsyncValue.data(stats);
      },
    );
  }

  Future<void> refresh() async {
    await _fetchDashboardStats();
  }
}
