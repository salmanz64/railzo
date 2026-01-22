import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/route.dart';
import '../../../data/repositories/admin_route_repository.dart';

part 'route_view_model.g.dart';

@riverpod
class RouteViewModel extends _$RouteViewModel {
  late AdminRouteRepository _repo;

  List<Route> _allRoutes = [];
  String? _searchQuery;

  @override
  AsyncValue<List<Route>> build() {
    _repo = ref.watch(adminRouteRepositoryProvider);
    return const AsyncValue.loading();
  }

  String? get searchQuery => _searchQuery;
  List<Route> get fullList => _allRoutes;

  Future<void> fetchAllRoutes() async {
    state = const AsyncValue.loading();

    final res = await _repo.getAllRoutes();

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (routes) {
        _allRoutes = routes;
        state = AsyncValue.data(routes);
      },
    );
  }

  Future<void> createRoute({
    required String source,
    required String destination,
    required List<RouteStop> stops,
    required int durationMinutes,
    required double distance,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.createRoute(
      source: source,
      destination: destination,
      stops: stops,
      durationMinutes: durationMinutes,
      distance: distance,
    );

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllRoutes(),
    );
  }

  Future<void> updateRoute({
    required String id,
    required String source,
    required String destination,
    required List<RouteStop> stops,
    required int durationMinutes,
    required double distance,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.updateRoute(
      id: id,
      source: source,
      destination: destination,
      stops: stops,
      durationMinutes: durationMinutes,
      distance: distance,
    );

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllRoutes(),
    );
  }

  Future<void> deleteRoute(String id) async {
    state = const AsyncValue.loading();

    final res = await _repo.deleteRoute(id: id);

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllRoutes(),
    );
  }

  Future<void> search(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      state = AsyncValue.data(_allRoutes);
      return;
    }

    final filtered =
        _allRoutes
            .where(
              (r) =>
                  r.source.toLowerCase().contains(query.toLowerCase()) ||
                  r.destination.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    state = AsyncValue.data(filtered);
  }

  Future<void> resetSearch() async {
    _searchQuery = null;
    state = AsyncValue.data(_allRoutes);
  }
}
