import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/failure/admin_failure.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../data/models/route.dart';

part 'admin_route_repository.g.dart';

@riverpod
AdminRouteRepository adminRouteRepository(Ref ref) {
  return AdminRouteRepository();
}

class AdminRouteRepository {
  final FirestoreService _firestore = FirestoreService();
  static const String _collection = 'routes';

  Future<Either<AdminFailure, Route>> createRoute({
    required String source,
    required String destination,
    required List<RouteStop> stops,
    required int durationMinutes,
    required double distance,
  }) async {
    final routeData = {
      'source': source,
      'destination': destination,
      'stops': stops.map((s) => s.toJson()).toList(),
      'durationMinutes': durationMinutes,
      'distance': distance,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final result = await _firestore.addDocument(
      collectionPath: _collection,
      data: routeData,
    );

    return result.match(
      (failure) => Left(failure),
      (id) => Right(Route(
        id: id,
        source: source,
        destination: destination,
        stops: stops,
        durationMinutes: durationMinutes,
        distance: distance,
      )),
    );
  }

  Future<Either<AdminFailure, List<Route>>> getAllRoutes() async {
    return await _firestore.getCollection(
      collectionPath: _collection,
      fromJson: (data) => Route.fromJson(data),
    );
  }

  Future<Either<AdminFailure, Route>> updateRoute({
    required String id,
    required String source,
    required String destination,
    required List<RouteStop> stops,
    required int durationMinutes,
    required double distance,
  }) async {
    final routeData = {
      'source': source,
      'destination': destination,
      'stops': stops.map((s) => s.toJson()).toList(),
      'durationMinutes': durationMinutes,
      'distance': distance,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final result = await _firestore.updateDocument(
      collectionPath: _collection,
      documentId: id,
      data: routeData,
    );

    return result.match(
      (failure) => Left(failure),
      (_) => Right(Route(
        id: id,
        source: source,
        destination: destination,
        stops: stops,
        durationMinutes: durationMinutes,
        distance: distance,
      )),
    );
  }

  Future<Either<AdminFailure, void>> deleteRoute({
    required String id,
  }) async {
    return await _firestore.deleteDocument(
      collectionPath: _collection,
      documentId: id,
    );
  }

  Future<Either<AdminFailure, List<Route>>> searchRoutes({
    required String query,
  }) async {
    final result = await getAllRoutes();

    return result.match(
      (failure) => Left(failure),
      (routes) {
        final filtered = routes
            .where((r) =>
                r.source.toLowerCase().contains(query.toLowerCase()) ||
                r.destination.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return Right(filtered);
      },
    );
  }
}
