import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/failure/admin_failure.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../data/models/train.dart';

part 'admin_train_repository.g.dart';

@riverpod
AdminTrainRepository adminTrainRepository(Ref ref) {
  return AdminTrainRepository();
}

class AdminTrainRepository {
  final FirestoreService _firestore = FirestoreService();
  static const String _collection = 'trains';

  Future<Either<AdminFailure, Train>> createTrain({
    required String name,
    required String number,
    required String type,
    required List<String> availableClasses,
  }) async {
    print('🚂 AdminTrainRepository: Creating train...');
    print('  Name: $name');
    print('  Number: $number');
    print('  Type: $type');
    print('  Classes: $availableClasses');

    final trainData = {
      'name': name,
      'number': number,
      'type': type,
      'availableClasses': availableClasses,
    };

    print('  Data to save: $trainData');
    print('  Collection: $_collection');

    final result = await _firestore.addDocument(
      collectionPath: _collection,
      data: trainData,
    );

    return result.match(
      (failure) {
        print('❌ FAILED to create train: ${failure.message}');
        return Left(failure);
      },
      (id) {
        print('✅ Train created with ID: $id');
        return Right(Train(
          id: id,
          name: name,
          number: number,
          type: type,
          availableClasses: availableClasses,
        ));
      },
    );
  }

  Future<Either<AdminFailure, List<Train>>> getAllTrains() async {
    print('📋 AdminTrainRepository: Fetching all trains from $_collection...');

    final result = await _firestore.getCollection(
      collectionPath: _collection,
      fromJson: (data) {
        print('  📝 fromJson called with data: $data');
        return Train.fromJson(data);
      },
    );

    return result.match(
      (failure) {
        print('❌ FAILED to fetch trains: ${failure.message}');
        return Left(failure);
      },
      (trains) {
        print('✅ Fetched ${trains.length} trains');
        for (var train in trains) {
          print('  - ${train.id}: ${train.name} (${train.number})');
        }
        return Right(trains);
      },
    );
  }

  Future<Either<AdminFailure, Train>> updateTrain({
    required String id,
    required String name,
    required String number,
    required String type,
    required List<String> availableClasses,
  }) async {
    final trainData = {
      'name': name,
      'number': number,
      'type': type,
      'availableClasses': availableClasses,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final result = await _firestore.updateDocument(
      collectionPath: _collection,
      documentId: id,
      data: trainData,
    );

    return result.match(
      (failure) => Left(failure),
      (_) => Right(Train(
        id: id,
        name: name,
        number: number,
        type: type,
        availableClasses: availableClasses,
      )),
    );
  }

  Future<Either<AdminFailure, void>> deleteTrain({
    required String id,
  }) async {
    return await _firestore.deleteDocument(
      collectionPath: _collection,
      documentId: id,
    );
  }

  Future<Either<AdminFailure, List<Train>>> searchTrains({
    required String query,
  }) async {
    final result = await getAllTrains();

    return result.match(
      (failure) => Left(failure),
      (trains) {
        final filtered = trains
            .where((t) =>
                t.name.toLowerCase().contains(query.toLowerCase()) ||
                t.number.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return Right(filtered);
      },
    );
  }
}
