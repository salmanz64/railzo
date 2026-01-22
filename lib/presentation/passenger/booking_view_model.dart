import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/booking.dart';
import '../../../data/repositories/booking_repository.dart';

part 'booking_view_model.g.dart';

@riverpod
class BookingViewModel extends _$BookingViewModel {
  late BookingRepository _repo;

  // Store full unfiltered list
  List<Booking> _allBookings = [];

  // Filters (UI state memory)
  String? _selectedStatus;
  String? _searchQuery;

  @override
  AsyncValue<List<Booking>> build() {
    _repo = ref.watch(bookingRepositoryProvider);
    return const AsyncValue.loading();
  }

  String? get selectedStatus => _selectedStatus;
  String? get searchQuery => _searchQuery;
  List<Booking> get fullList => _allBookings;

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
    _selectedStatus = status;

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
    _searchQuery = query;

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
    _selectedStatus = null;
    _searchQuery = null;
    state = AsyncValue.data(_allBookings);
  }

  // ---------------------------------------------------------
  // GET CONFIRMED BOOKINGS
  // ---------------------------------------------------------
  List<Booking> get confirmedBookings =>
      _allBookings.where((b) => b.status == 'Confirmed').toList();

  // ---------------------------------------------------------
  // GET CANCELLED BOOKINGS
  // ---------------------------------------------------------
  List<Booking> get cancelledBookings =>
      _allBookings.where((b) => b.status == 'Cancelled').toList();
}
