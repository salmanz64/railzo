import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/failure/admin_failure.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../data/models/pricing.dart';

part 'admin_pricing_repository.g.dart';

@riverpod
AdminPricingRepository adminPricingRepository(Ref ref) {
  return AdminPricingRepository();
}

class AdminPricingRepository {
  final FirestoreService _firestore = FirestoreService();
  static const String _collection = 'pricing';

  Future<Either<AdminFailure, List<Pricing>>> getAllPricing() async {
    return await _firestore.getCollection(
      collectionPath: _collection,
      fromJson: (data) => Pricing.fromJson(data),
    );
  }

  Future<Either<AdminFailure, Pricing>> createPricing({
    required String travelClass,
    required double basePricePerKm,
    required double serviceCharge,
    required double gst,
  }) async {
    final pricingData = {
      'travelClass': travelClass,
      'basePricePerKm': basePricePerKm,
      'serviceCharge': serviceCharge,
      'gst': gst,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final result = await _firestore.addDocument(
      collectionPath: _collection,
      data: pricingData,
    );

    return result.match(
      (failure) => Left(failure),
      (id) => Right(Pricing(
        id: id,
        travelClass: travelClass,
        basePricePerKm: basePricePerKm,
        serviceCharge: serviceCharge,
        gst: gst,
      )),
    );
  }

  Future<Either<AdminFailure, Pricing>> updatePricing({
    required String id,
    required String travelClass,
    required double basePricePerKm,
    required double serviceCharge,
    required double gst,
  }) async {
    final pricingData = {
      'travelClass': travelClass,
      'basePricePerKm': basePricePerKm,
      'serviceCharge': serviceCharge,
      'gst': gst,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final result = await _firestore.updateDocument(
      collectionPath: _collection,
      documentId: id,
      data: pricingData,
    );

    return result.match(
      (failure) => Left(failure),
      (_) => Right(Pricing(
        id: id,
        travelClass: travelClass,
        basePricePerKm: basePricePerKm,
        serviceCharge: serviceCharge,
        gst: gst,
      )),
    );
  }

  Future<Either<AdminFailure, void>> deletePricing({
    required String id,
  }) async {
    return await _firestore.deleteDocument(
      collectionPath: _collection,
      documentId: id,
    );
  }

  Future<Either<AdminFailure, double>> calculateFare({
    required String travelClass,
    required double distance,
  }) async {
    try {
      final result = await getAllPricing();

      return result.match(
        (failure) => Left(failure),
        (pricingList) {
          final pricing = pricingList.firstWhere(
            (p) => p.travelClass == travelClass,
            orElse: () => pricingList[0],
          );

          final basePrice = distance * pricing.basePricePerKm;
          final serviceCharge = pricing.serviceCharge;
          final gst = (basePrice + serviceCharge) * (pricing.gst / 100);
          final total = basePrice + serviceCharge + gst;

          return Right(total);
        },
      );
    } catch (e) {
      return Left(AdminFailure('Fare calculation failed: ${e.toString()}'));
    }
  }
}
