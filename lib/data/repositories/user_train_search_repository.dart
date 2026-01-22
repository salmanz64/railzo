import 'package:fpdart/fpdart.dart';
import '../../core/failure/admin_failure.dart';
import '../../core/firebase/firestore_service.dart';
import '../../data/models/train.dart';
import '../../data/models/route.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/booking_repository.dart';

class UserTrainSearchRepository {
  final FirestoreService _firestore = FirestoreService();
  final BookingRepository _bookingRepository = BookingRepository();

  Future<Either<AdminFailure, List<TrainSearchResult>>> searchTrains({
    required String from,
    required String to,
    required DateTime date,
    required String travelClass,
  }) async {
    try {
      final routesResult = await _firestore.getCollection(
        collectionPath: 'routes',
        fromJson: (data) => Route.fromJson(data),
      );

      final trainsResult = await _firestore.getCollection(
        collectionPath: 'trains',
        fromJson: (data) => Train.fromJson(data),
      );

      final schedulesResult = await _firestore.getCollection(
        collectionPath: 'schedules',
        fromJson: (data) => Schedule.fromJson(data),
      );

      return routesResult.fold((failure) => Left(failure), (routes) {
        final matchingRoutes = routes.where((route) {
          final sourceMatch =
              route.source.toLowerCase().contains(from.toLowerCase()) ||
              from.toLowerCase().contains(route.source.toLowerCase());
          final destMatch =
              route.destination.toLowerCase().contains(to.toLowerCase()) ||
              to.toLowerCase().contains(route.destination.toLowerCase());
          return sourceMatch && destMatch;
        }).toList();

        return trainsResult.fold((failure) => Future.value(Left(failure)), (
          trains,
        ) async {
          final filteredTrains = trains.where((train) {
            return train.availableClasses.contains(travelClass) &&
                matchingRoutes.any((route) => true);
          }).toList();

          final results = await Future.wait(
            filteredTrains.map((train) async {
              final route = matchingRoutes.isNotEmpty
                  ? matchingRoutes.first
                  : null;
              final schedule = schedulesResult.fold(
                (failure) => null,
                (schedules) =>
                    schedules.where((s) => s.trainId == train.id).firstOrNull,
              );

              // Fetch reserved seats to calculate availability
              int reservedCount = 0;
              final reservedResult = await _bookingRepository.getReservedSeats(
                trainId: train.id,
                journeyDate: date,
              );

              reservedResult.fold(
                (l) => print('Error fetching seats: ${l.message}'),
                (seats) => reservedCount = seats.length,
              );

              // Total capacity: 3 coaches * 32 seats = 96
              final totalCapacity = 96;
              // Ensure we don't show negative seats if data is somehow off
              final availableSeats = (totalCapacity - reservedCount).clamp(
                0,
                totalCapacity,
              );

              print(
                '🔍 Train ${train.name} ($date): Reserved $reservedCount, Available $availableSeats',
              );

              return TrainSearchResult(
                train: train,
                route: route,
                schedule: schedule,
                travelClass: travelClass,
                date: date,
                availableSeats: availableSeats,
              );
            }),
          );

          return Right(results);
        });
      });
    } catch (e) {
      return Left(AdminFailure('Failed to search trains: ${e.toString()}'));
    }
  }
}

class TrainSearchResult {
  final Train train;
  final Route? route;
  final Schedule? schedule;
  final String travelClass;
  final DateTime date;
  final int availableSeats;

  TrainSearchResult({
    required this.train,
    required this.route,
    required this.schedule,
    required this.travelClass,
    required this.date,
    required this.availableSeats,
  });

  String get formattedPrice {
    final basePrice = getBasePriceForClass(travelClass);
    return '₹$basePrice';
  }

  int get price => getBasePriceForClass(travelClass);

  String get departureTime => schedule?.departureTime ?? 'N/A';
  String get arrivalTime => _calculateArrivalTime();
  String get duration {
    if (route != null) {
      final hours = route!.durationMinutes ~/ 60;
      final minutes = route!.durationMinutes % 60;
      return '${hours}h ${minutes}m';
    }
    return 'N/A';
  }

  String _calculateArrivalTime() {
    if (schedule?.departureTime == null || route == null) return 'N/A';

    try {
      final departureParts = schedule!.departureTime.split(':');
      final departureHour = int.parse(departureParts[0]);
      final departureMinute = int.parse(departureParts[1]);

      final departureDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        departureHour,
        departureMinute,
      );

      final arrivalDateTime = departureDateTime.add(
        Duration(minutes: route!.durationMinutes),
      );
      return '${arrivalDateTime.hour.toString().padLeft(2, '0')}:${arrivalDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  int getBasePriceForClass(String className) {
    switch (className) {
      case '1st AC':
        return 3500;
      case '2nd AC':
        return 2450;
      case '3rd AC':
        return 1250;
      case 'Sleeper':
        return 550;
      default:
        return 1000;
    }
  }
}
