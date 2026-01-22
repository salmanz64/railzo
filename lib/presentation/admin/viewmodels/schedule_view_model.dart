import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/schedule.dart';
import '../../../data/repositories/admin_schedule_repository.dart';

part 'schedule_view_model.g.dart';

@riverpod
class ScheduleViewModel extends _$ScheduleViewModel {
  late AdminScheduleRepository _repo;

  List<Schedule> _allSchedules = [];
  String? _searchQuery;

  @override
  AsyncValue<List<Schedule>> build() {
    _repo = ref.watch(adminScheduleRepositoryProvider);
    return const AsyncValue.loading();
  }

  String? get searchQuery => _searchQuery;
  List<Schedule> get fullList => _allSchedules;

  Future<void> fetchAllSchedules() async {
    state = const AsyncValue.loading();

    final res = await _repo.getAllSchedules();

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (schedules) {
        _allSchedules = schedules;
        state = AsyncValue.data(schedules);
      },
    );
  }

  Future<void> createSchedule({
    required String trainId,
    required String trainName,
    required String routeId,
    required String departureTime,
    required String days,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.createSchedule(
      trainId: trainId,
      trainName: trainName,
      routeId: routeId,
      departureTime: departureTime,
      days: days,
    );

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllSchedules(),
    );
  }

  Future<void> updateSchedule({
    required String id,
    required String trainId,
    required String trainName,
    required String routeId,
    required String departureTime,
    required String days,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.updateSchedule(
      id: id,
      trainId: trainId,
      trainName: trainName,
      routeId: routeId,
      departureTime: departureTime,
      days: days,
    );

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllSchedules(),
    );
  }

  Future<void> deleteSchedule(String id) async {
    state = const AsyncValue.loading();

    final res = await _repo.deleteSchedule(id: id);

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllSchedules(),
    );
  }

  Future<void> search(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      state = AsyncValue.data(_allSchedules);
      return;
    }

    final filtered =
        _allSchedules
            .where(
              (s) =>
                  s.trainName.toLowerCase().contains(query.toLowerCase()) ||
                  s.routeId.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    state = AsyncValue.data(filtered);
  }

  Future<void> resetSearch() async {
    _searchQuery = null;
    state = AsyncValue.data(_allSchedules);
  }
}
