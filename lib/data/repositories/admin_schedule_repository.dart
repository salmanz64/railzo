import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/failure/admin_failure.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../data/models/schedule.dart';

part 'admin_schedule_repository.g.dart';

@riverpod
AdminScheduleRepository adminScheduleRepository(Ref ref) {
  return AdminScheduleRepository();
}

class AdminScheduleRepository {
  final FirestoreService _firestore = FirestoreService();
  static const String _collection = 'schedules';

  Future<Either<AdminFailure, Schedule>> createSchedule({
    required String trainId,
    required String trainName,
    required String routeId,
    required String departureTime,
    required String days,
  }) async {
    final scheduleData = {
      'trainId': trainId,
      'trainName': trainName,
      'routeId': routeId,
      'departureTime': departureTime,
      'days': days,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final result = await _firestore.addDocument(
      collectionPath: _collection,
      data: scheduleData,
    );

    return result.match(
      (failure) => Left(failure),
      (id) => Right(Schedule(
        id: id,
        trainId: trainId,
        trainName: trainName,
        routeId: routeId,
        departureTime: departureTime,
        days: days,
      )),
    );
  }

  Future<Either<AdminFailure, List<Schedule>>> getAllSchedules() async {
    return await _firestore.getCollection(
      collectionPath: _collection,
      fromJson: (data) => Schedule.fromJson(data),
    );
  }

  Future<Either<AdminFailure, Schedule>> updateSchedule({
    required String id,
    required String trainId,
    required String trainName,
    required String routeId,
    required String departureTime,
    required String days,
  }) async {
    final scheduleData = {
      'trainId': trainId,
      'trainName': trainName,
      'routeId': routeId,
      'departureTime': departureTime,
      'days': days,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final result = await _firestore.updateDocument(
      collectionPath: _collection,
      documentId: id,
      data: scheduleData,
    );

    return result.match(
      (failure) => Left(failure),
      (_) => Right(Schedule(
        id: id,
        trainId: trainId,
        trainName: trainName,
        routeId: routeId,
        departureTime: departureTime,
        days: days,
      )),
    );
  }

  Future<Either<AdminFailure, void>> deleteSchedule({
    required String id,
  }) async {
    return await _firestore.deleteDocument(
      collectionPath: _collection,
      documentId: id,
    );
  }

  Future<Either<AdminFailure, List<Schedule>>> searchSchedules({
    required String query,
  }) async {
    final result = await getAllSchedules();

    return result.match(
      (failure) => Left(failure),
      (schedules) {
        final filtered = schedules
            .where((s) =>
                s.trainName.toLowerCase().contains(query.toLowerCase()) ||
                s.routeId.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return Right(filtered);
      },
    );
  }
}
