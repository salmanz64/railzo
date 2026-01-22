import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/failure/admin_failure.dart';
import '../../../data/models/train.dart';
import '../../../data/repositories/admin_train_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'train_view_model.g.dart';

@riverpod
class TrainViewModel extends _$TrainViewModel {
  late AdminTrainRepository _repo;

  // Store full unfiltered list
  List<Train> _allTrains = [];

  // Filters (UI state memory)
  String? _searchQuery;

  @override
  AsyncValue<List<Train>> build() {
    _repo = ref.watch(adminTrainRepositoryProvider);
    // Don't auto-fetch - let screen trigger it when needed
    return const AsyncValue.loading();
  }

  String? get searchQuery => _searchQuery;
  List<Train> get fullList => _allTrains; // For counters

  // ---------------------------------------------------------
  // 🔹 Base: Fetch All Trains
  // ---------------------------------------------------------
  Future<void> fetchAllTrains() async {
    print('🔁 TrainViewModel: Fetching trains...');
    state = const AsyncValue.loading();

    final res = await _repo.getAllTrains();

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (trains) {
        _allTrains = trains; // store original list
        state = AsyncValue.data(trains);
      },
    );
  }

  // ---------------------------------------------------------
  // 🟢 Create Train + Auto-refresh
  // ---------------------------------------------------------
  Future<void> createTrain({
    required String name,
    required String number,
    required String type,
    required List<String> availableClasses,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.createTrain(
      name: name,
      number: number,
      type: type,
      availableClasses: availableClasses,
    );

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        fetchAllTrains();
      },
    );
  }

  // ---------------------------------------------------------
  // 🟡 Update Train + Auto-refresh
  // ---------------------------------------------------------
  Future<void> updateTrain({
    required String id,
    required String name,
    required String number,
    required String type,
    required List<String> availableClasses,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.updateTrain(
      id: id,
      name: name,
      number: number,
      type: type,
      availableClasses: availableClasses,
    );

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        fetchAllTrains();
      },
    );
  }

  // ---------------------------------------------------------
  // 🔴 Delete Train + Auto-refresh
  // ---------------------------------------------------------
  Future<void> deleteTrain(String id) async {
    state = const AsyncValue.loading();

    final res = await _repo.deleteTrain(id: id);

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllTrains(),
    );
  }

  // ---------------------------------------------------------
  // 🔍 SEARCH Train (LOCAL SEARCH)
  // ---------------------------------------------------------
  Future<void> search(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      state = AsyncValue.data(_allTrains);
      return;
    }

    final filtered =
        _allTrains
            .where(
              (t) => t.name.toLowerCase().contains(query.toLowerCase()) ||
                  t.number.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    state = AsyncValue.data(filtered);
  }

  // ---------------------------------------------------------
  // RESET SEARCH
  // ---------------------------------------------------------
  Future<void> resetSearch() async {
    _searchQuery = null;
    state = AsyncValue.data(_allTrains);
  }
}
