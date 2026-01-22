import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/booking.dart';
import '../../../data/repositories/booking_repository.dart';

part 'booking_view_model.g.dart';

@riverpod
class BookingViewModel extends _$BookingViewModel {
  late BookingRepository _repo;
  List<Booking> _allBookings = [];

  @override
  AsyncValue<List<Booking>> build() {
    _repo = ref.watch(bookingRepositoryProvider);
    return const AsyncValue.loading();
  }

  // ---------------------------------------------------------
  // 🔹 Base: Fetch All Bookings
  // ---------------------------------------------------------
  Future<void> fetchAllBookings() async {
    state = const AsyncValue.loading();

    final res = await _repo.getAllBookings();

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (bookings) {
        _allBookings = bookings;
        state = AsyncValue.data(bookings);
      },
    );
  }

  // ---------------------------------------------------------
  // 🔍 FILTER BY STATUS
  // ---------------------------------------------------------
  Future<void> filterByStatus(String status) async {
    final filtered =
        _allBookings
            .where((b) => b.status.toLowerCase() == status.toLowerCase())
            .toList();

    state = AsyncValue.data(filtered);
  }

  // ---------------------------------------------------------
  // 🔍 SEARCH (LOCAL SEARCH)
  // ---------------------------------------------------------
  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(_allBookings);
      return;
    }

    final filtered =
        _allBookings
            .where((b) =>
                b.trainName.toLowerCase().contains(query.toLowerCase()) ||
                b.pnr.toLowerCase().contains(query.toLowerCase()))
            .toList();

    state = AsyncValue.data(filtered);
  }

  // ---------------------------------------------------------
  // RESET FILTERS
  // ---------------------------------------------------------
  Future<void> resetFilters() async {
    state = AsyncValue.data(_allBookings);
  }
}
