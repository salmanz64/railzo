import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/failure/admin_failure.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<AdminFailure, List<T>>> getCollection<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    print('📝 FirestoreService: Fetching collection $collectionPath...');
    try {
      final snapshot = await _firestore.collection(collectionPath).get();
      print('  ✅ Got ${snapshot.docs.length} documents from Firestore');

      final items = <T>[];
      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        final dataWithId = Map<String, dynamic>.from(data);
        dataWithId['id'] = doc.id;
        print('  📋 Document $i (${doc.id}):');
        print('     Raw data: $data');

        try {
          final item = fromJson(dataWithId);
          print('     ✅ Parsed successfully: $item');
          items.add(item);
        } catch (e) {
          print('     ❌ Failed to parse document $i: $e');
          rethrow;
        }
      }

      print('  📊 Returning ${items.length} items');
      return Right(items);
    } catch (e) {
      print('  ❌ ERROR in getCollection: $e');
      return Left(AdminFailure('Failed to fetch collection: ${e.toString()}'));
    }
  }

  Future<Either<AdminFailure, T>> getDocument<T>({
    required String collectionPath,
    required String documentId,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final doc = await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .get();
      if (!doc.exists) {
        return Left(AdminFailure('Document not found'));
      }
      return Right(fromJson(doc.data()!));
    } catch (e) {
      return Left(AdminFailure('Failed to fetch document: ${e.toString()}'));
    }
  }

  Future<Either<AdminFailure, String>> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    print('📝 FirestoreService: Adding document to $collectionPath');
    print('  Data: $data');
    try {
      final docRef = await _firestore.collection(collectionPath).add(data);
      print('✅ Document added with ID: ${docRef.id}');
      return Right(docRef.id);
    } catch (e) {
      print('❌ ERROR adding document: $e');
      print('  Error type: ${e.runtimeType}');
      return Left(AdminFailure('Failed to add document: ${e.toString()}'));
    }
  }

  Future<Either<AdminFailure, void>> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).update(data);
      return Right(null);
    } catch (e) {
      return Left(AdminFailure('Failed to update document: ${e.toString()}'));
    }
  }

  Future<Either<AdminFailure, void>> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).delete();
      return Right(null);
    } catch (e) {
      return Left(AdminFailure('Failed to delete document: ${e.toString()}'));
    }
  }

  Future<Either<AdminFailure, List<T>>> queryCollection<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic>) fromJson,
    String? field,
    dynamic isEqualTo,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath);

      if (field != null && isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final items = <T>[];

      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data() as Map<String, dynamic>;

        // Inject ID
        final dataWithId = Map<String, dynamic>.from(data);
        dataWithId['id'] = doc.id;

        try {
          final item = fromJson(dataWithId);
          items.add(item);
        } catch (e) {
          print(
            '❌ Failed to parse document ${doc.id} in queryCollection ($collectionPath)',
          );
          print('   Data: $dataWithId');
          print('   Error: $e');
          // We rethrow to let the UI show the error, now with more logs printed.
          // Or we could skip this item? The user wants to know why it failed.
          // Let's wrapping the error to be more descriptive for the UI toast if possible,
          // but for now rethrowing with print logs is a good first step.
          // Actually, let's include the ID in the error message so the UI shows it.
          throw FormatException('Failed to parse doc ${doc.id}: $e');
        }
      }

      return Right(items);
    } catch (e) {
      return Left(AdminFailure('Failed to query collection: ${e.toString()}'));
    }
  }
}
