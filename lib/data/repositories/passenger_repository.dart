import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/failure/admin_failure.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../data/models/passenger.dart';

part 'passenger_repository.g.dart';

@riverpod
PassengerRepository passengerRepository(Ref ref) {
  return PassengerRepository();
}

class PassengerRepository {
  final FirestoreService _firestore = FirestoreService();
  static const String _collection = 'passengers';

  Future<Either<AdminFailure, Passenger>> createPassenger({
    required String name,
    required int age,
    required String gender,
  }) async {
    final passengerData = {
      'name': name,
      'age': age,
      'gender': gender,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final result = await _firestore.addDocument(
      collectionPath: _collection,
      data: passengerData,
    );

    return result.match(
      (failure) => Left(failure),
      (id) => Right(Passenger(
        id: id,
        name: name,
        age: age,
        gender: gender,
      )),
    );
  }

  Future<Either<AdminFailure, List<Passenger>>> getAllPassengers() async {
    return await _firestore.getCollection(
      collectionPath: _collection,
      fromJson: (data) => Passenger.fromJson(data),
    );
  }

  Future<Either<AdminFailure, Passenger>> updatePassenger({
    required String id,
    required String name,
    required int age,
    required String gender,
  }) async {
    final passengerData = {
      'name': name,
      'age': age,
      'gender': gender,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final result = await _firestore.updateDocument(
      collectionPath: _collection,
      documentId: id,
      data: passengerData,
    );

    return result.match(
      (failure) => Left(failure),
      (_) => Right(Passenger(
        id: id,
        name: name,
        age: age,
        gender: gender,
      )),
    );
  }

  Future<Either<AdminFailure, void>> deletePassenger({
    required String id,
  }) async {
    return await _firestore.deleteDocument(
      collectionPath: _collection,
      documentId: id,
    );
  }

  Future<Either<AdminFailure, Passenger?>> getPassengerById({
    required String id,
  }) async {
    final result = await _firestore.getDocument(
      collectionPath: _collection,
      documentId: id,
      fromJson: (data) => Passenger.fromJson(data),
    );

    return result.match(
      (failure) => Left(failure),
      (passenger) => Right(passenger),
    );
  }

  Future<Either<AdminFailure, List<Passenger>>> searchPassengers({
    required String query,
  }) async {
    final result = await getAllPassengers();

    return result.match(
      (failure) => Left(failure),
      (passengers) {
        final filtered = passengers
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return Right(filtered);
      },
    );
  }

  Future<Either<AdminFailure, List<Passenger>>> filterPassengersByGender({
    required String gender,
  }) async {
    return await _firestore.queryCollection(
      collectionPath: _collection,
      fromJson: (data) => Passenger.fromJson(data),
      field: 'gender',
      isEqualTo: gender,
    );
  }
}
