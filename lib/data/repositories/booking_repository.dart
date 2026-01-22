import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/failure/admin_failure.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../data/models/booking.dart';

part 'booking_repository.g.dart';

@riverpod
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository();
}

class BookingRepository {
  final FirestoreService _firestore = FirestoreService();
  static const String _collection = 'bookings';

  Future<Either<AdminFailure, Booking>> createBooking({
    required String pnr,
    required String trainId,
    required String trainName,
    required String routeId,
    required String travelClass,
    required List<String> selectedSeats,
    required List<Map<String, dynamic>> passengers,
    required double totalAmount,
    required String journeyDate,
    required String userId,
    String status = 'Confirmed',
  }) async {
    final bookingData = {
      'pnr': pnr,
      'trainId': trainId,
      'trainName': trainName,
      'routeId': routeId,
      'travelClass': travelClass,
      'selectedSeats': selectedSeats,
      'passengers': passengers,
      'totalAmount': totalAmount,
      'journeyDate': journeyDate,
      'status': status,
      'bookingDate': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'userId': userId,
    };

    final result = await _firestore.addDocument(
      collectionPath: _collection,
      data: bookingData,
    );

    return result.match(
      (failure) => Left(failure),
      (id) => Right(
        Booking(
          id: id,
          pnr: pnr,
          trainId: trainId,
          trainName: trainName,
          routeId: routeId,
          travelClass: travelClass,
          selectedSeats: selectedSeats,
          passengers: passengers,
          totalAmount: totalAmount,
          journeyDate: DateTime.parse(journeyDate),
          status: status,
          bookingDate: DateTime.now(),
          userId: userId,
        ),
      ),
    );
  }

  Future<Either<AdminFailure, List<Booking>>> getBookingsByUserId({
    required String userId,
  }) async {
    return await _firestore.queryCollection(
      collectionPath: _collection,
      fromJson: (data) => Booking.fromJson(data),
      field: 'userId',
      isEqualTo: userId,
    );
  }

  Future<Either<AdminFailure, List<Booking>>> getAllBookings() async {
    return await _firestore.getCollection(
      collectionPath: _collection,
      fromJson: (data) => Booking.fromJson(data),
    );
  }

  Future<Either<AdminFailure, List<String>>> getReservedSeats({
    required String trainId,
    required DateTime journeyDate,
  }) async {
    // Format date to match how it's stored/queried.
    // Assuming accurate match is required on the date part.
    // Ideally we match the whole ISO string date part,
    // but Booking has DateTime. We should probably filter on client side
    // or ensure exact match if logical.
    // For now, let's fetch by trainId and filter by date locally to be safe
    // against time differences if any.

    final result = await _firestore.queryCollection(
      collectionPath: _collection,
      fromJson: (data) => Booking.fromJson(data),
      field: 'trainId',
      isEqualTo: trainId,
    );

    return result.match(
      (failure) {
        debugPrint(
          'getReservedSeats: Firestore Query Failed: ${failure.message}',
        );
        return Left(failure);
      },
      (bookings) {
        debugPrint(
          'getReservedSeats: Found ${bookings.length} bookings for train $trainId',
        );

        final reserved = bookings
            .where((b) {
              final isConfirmed = b.status == 'Confirmed';

              // Robust date comparison: YYYY-MM-DD
              final bookingDateStr =
                  "${b.journeyDate.year}-${b.journeyDate.month}-${b.journeyDate.day}";
              final queryDateStr =
                  "${journeyDate.year}-${journeyDate.month}-${journeyDate.day}";
              final isDateMatch = bookingDateStr == queryDateStr;

              if (!isDateMatch) {
                // debugPrint('Date mismatch: DB($bookingDateStr) != Query($queryDateStr)');
              }

              return isConfirmed && isDateMatch;
            })
            .expand((b) => b.selectedSeats)
            .toList();

        debugPrint(
          'getReservedSeats: Returned ${reserved.length} reserved seats: $reserved',
        );
        return Right(reserved);
      },
    );
  }

  Future<Either<AdminFailure, Booking>> updateBookingStatus({
    required String id,
    required String status,
  }) async {
    final result = await _firestore.updateDocument(
      collectionPath: _collection,
      documentId: id,
      data: {'status': status, 'updatedAt': DateTime.now().toIso8601String()},
    );

    return result.match((failure) => Left(failure), (_) async {
      final bookingResult = await _firestore.getDocument(
        collectionPath: _collection,
        documentId: id,
        fromJson: (data) => Booking.fromJson(data),
      );
      return bookingResult;
    });
  }

  Future<Either<AdminFailure, void>> cancelBooking({required String id}) async {
    return await _firestore.updateDocument(
      collectionPath: _collection,
      documentId: id,
      data: {
        'status': 'Cancelled',
        'cancelledAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<Either<AdminFailure, Booking?>> getBookingById({
    required String id,
  }) async {
    final result = await _firestore.getDocument(
      collectionPath: _collection,
      documentId: id,
      fromJson: (data) => Booking.fromJson(data),
    );

    return result.match(
      (failure) => Left(failure),
      (booking) => Right(booking),
    );
  }

  Future<Either<AdminFailure, List<Booking>>> searchBookingsByPNR({
    required String pnr,
  }) async {
    final result = await _firestore.queryCollection(
      collectionPath: _collection,
      fromJson: (data) => Booking.fromJson(data),
      field: 'pnr',
      isEqualTo: pnr,
    );

    return result.match((failure) => Left(failure), (bookings) {
      final filtered = bookings
          .where((b) => b.pnr.toLowerCase().contains(pnr.toLowerCase()))
          .toList();
      return Right(filtered);
    });
  }

  Future<Either<AdminFailure, List<Booking>>> filterBookingsByStatus({
    required String status,
  }) async {
    return await _firestore.queryCollection(
      collectionPath: _collection,
      fromJson: (data) => Booking.fromJson(data),
      field: 'status',
      isEqualTo: status,
    );
  }

  Future<Either<AdminFailure, Map<String, dynamic>>>
  getBookingStatistics() async {
    final result = await getAllBookings();

    return result.match((failure) => Left(failure), (bookings) {
      final total = bookings.length;
      final confirmed = bookings.where((b) => b.status == 'Confirmed').length;
      final cancelled = bookings.where((b) => b.status == 'Cancelled').length;
      final waitlisted = bookings.where((b) => b.status == 'Waitlisted').length;
      final totalRevenue = bookings
          .where((b) => b.status == 'Confirmed')
          .fold<double>(0.0, (sum, b) => sum + b.totalAmount);

      return Right({
        'total': total,
        'confirmed': confirmed,
        'cancelled': cancelled,
        'waitlisted': waitlisted,
        'revenue': totalRevenue,
      });
    });
  }
}
