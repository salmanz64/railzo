import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/failure/admin_failure.dart';
import '../../../data/models/passenger.dart';
import '../../../data/repositories/passenger_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'passenger_view_model.g.dart';

@riverpod
class PassengerViewModel extends _$PassengerViewModel {
  late PassengerRepository _repo;

  List<Passenger> _allPassengers = [];

  String? _searchQuery;
  String? _selectedGender;

  @override
  AsyncValue<List<Passenger>> build() {
    _repo = ref.watch(passengerRepositoryProvider);
    return const AsyncValue.loading();
  }

  String? get searchQuery => _searchQuery;
  String? get selectedGender => _selectedGender;
  List<Passenger> get fullList => _allPassengers;

  Future<void> fetchAllPassengers() async {
    state = const AsyncValue.loading();

    final res = await _repo.getAllPassengers();

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (passengers) {
        _allPassengers = passengers;
        state = AsyncValue.data(passengers);
      },
    );
  }

  Future<void> createPassenger({
    required String name,
    required int age,
    required String gender,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.createPassenger(
      name: name,
      age: age,
      gender: gender,
    );

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllPassengers(),
    );
  }

  Future<void> updatePassenger({
    required String id,
    required String name,
    required int age,
    required String gender,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.updatePassenger(
      id: id,
      name: name,
      age: age,
      gender: gender,
    );

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllPassengers(),
    );
  }

  Future<void> deletePassenger(String id) async {
    state = const AsyncValue.loading();

    final res = await _repo.deletePassenger(id: id);

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllPassengers(),
    );
  }

  Future<void> search(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      state = AsyncValue.data(_allPassengers);
      return;
    }

    final filtered =
        _allPassengers
            .where(
              (p) => p.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    state = AsyncValue.data(filtered);
  }

  Future<void> filterByGender(String gender) async {
    _selectedGender = gender;

    final filtered =
        _allPassengers
            .where((p) => p.gender.toLowerCase() == gender.toLowerCase())
            .toList();

    state = AsyncValue.data(filtered);
  }

  Future<void> resetFilters() async {
    _searchQuery = null;
    _selectedGender = null;
    state = AsyncValue.data(_allPassengers);
  }

  List<Passenger> get malePassengers =>
      _allPassengers.where((p) => p.gender == 'Male').toList();

  List<Passenger> get femalePassengers =>
      _allPassengers.where((p) => p.gender == 'Female').toList();

  List<Passenger> get passengersByAge =>
      List.from(_allPassengers)..sort((a, b) => a.age.compareTo(b.age));
}
