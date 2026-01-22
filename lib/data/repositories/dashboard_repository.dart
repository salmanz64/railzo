import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/failure/admin_failure.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/dashboard_stats.dart';

part 'dashboard_repository.g.dart';

@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  return DashboardRepository();
}

class DashboardRepository {
  final FirestoreService _firestore = FirestoreService();
  static const String _collection = 'bookings';

  Future<Either<AdminFailure, DashboardStats>> getDashboardStats() async {
    final result = await _firestore.getCollection(
      collectionPath: _collection,
      fromJson: (data) => Booking.fromJson(data),
    );

    return result.match(
      (failure) => Left(failure),
      (bookings) {
        final stats = _calculateStats(bookings);
        return Right(stats);
      },
    );
  }

  DashboardStats _calculateStats(List<Booking> bookings) {
    int totalBookings = bookings.length;
    int confirmedBookings = 0;
    int cancelledBookings = 0;
    double totalRevenue = 0;

    final Map<String, int> trainBookings = {};
    final Map<String, int> classCount = {};

    for (final booking in bookings) {
      if (booking.status.toLowerCase() == 'confirmed') {
        confirmedBookings++;
        totalRevenue += booking.totalAmount;
      } else if (booking.status.toLowerCase() == 'cancelled') {
        cancelledBookings++;
      }

      final trainKey = booking.trainId;
      trainBookings[trainKey] = (trainBookings[trainKey] ?? 0) + 1;

      final classKey = booking.travelClass;
      classCount[classKey] = (classCount[classKey] ?? 0) + 1;
    }

    final sortedTrains = trainBookings.entries
        .map((e) => TrainStats(
              trainId: e.key,
              trainName: bookings
                  .firstWhere((b) => b.trainId == e.key,
                      orElse: () => bookings[0])
                  .trainName,
              bookingCount: e.value,
            ))
        .toList()
      ..sort((a, b) => b.bookingCount.compareTo(a.bookingCount));

    final popularTrains = sortedTrains.take(5).toList();

    return DashboardStats(
      totalBookings: totalBookings,
      confirmedBookings: confirmedBookings,
      cancelledBookings: cancelledBookings,
      totalRevenue: totalRevenue,
      popularTrains: popularTrains,
      classDistribution: classCount,
    );
  }
}
