import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/pricing.dart';
import '../../../data/repositories/admin_pricing_repository.dart';

part 'pricing_view_model.g.dart';

@riverpod
class PricingViewModel extends _$PricingViewModel {
  late AdminPricingRepository _repo;

  @override
  AsyncValue<List<Pricing>> build() {
    _repo = ref.watch(adminPricingRepositoryProvider);
    _initializeDefaultPricing();
    return const AsyncValue.loading();
  }

  Future<void> _initializeDefaultPricing() async {
    final existingPricing = await _repo.getAllPricing();
    
    existingPricing.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (pricing) async {
        if (pricing.isEmpty) {
          final defaultPricing = [
            {
              'travelClass': 'Sleeper',
              'basePricePerKm': 0.5,
              'serviceCharge': 30.0,
              'gst': 5.0,
            },
            {
              'travelClass': '3rd AC',
              'basePricePerKm': 1.2,
              'serviceCharge': 40.0,
              'gst': 5.0,
            },
            {
              'travelClass': '2nd AC',
              'basePricePerKm': 1.8,
              'serviceCharge': 50.0,
              'gst': 5.0,
            },
            {
              'travelClass': '1st AC',
              'basePricePerKm': 3.0,
              'serviceCharge': 70.0,
              'gst': 5.0,
            },
          ];

          for (var p in defaultPricing) {
            await _repo.createPricing(
              travelClass: p['travelClass'] as String,
              basePricePerKm: p['basePricePerKm'] as double,
              serviceCharge: p['serviceCharge'] as double,
              gst: p['gst'] as double,
            );
          }

          await fetchAllPricing();
        } else {
          state = AsyncValue.data(pricing);
        }
      },
    );
  }

  Future<void> fetchAllPricing() async {
    state = const AsyncValue.loading();

    final res = await _repo.getAllPricing();

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (pricing) {
        state = AsyncValue.data(pricing);
      },
    );
  }

  Future<void> updatePricing({
    required String id,
    required String travelClass,
    required double basePricePerKm,
    required double serviceCharge,
    required double gst,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.updatePricing(
      id: id,
      travelClass: travelClass,
      basePricePerKm: basePricePerKm,
      serviceCharge: serviceCharge,
      gst: gst,
    );

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllPricing(),
    );
  }

  Future<void> createPricing({
    required String travelClass,
    required double basePricePerKm,
    required double serviceCharge,
    required double gst,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.createPricing(
      travelClass: travelClass,
      basePricePerKm: basePricePerKm,
      serviceCharge: serviceCharge,
      gst: gst,
    );

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllPricing(),
    );
  }

  Future<void> deletePricing({
    required String id,
  }) async {
    state = const AsyncValue.loading();

    final res = await _repo.deletePricing(id: id);

    res.match(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => await fetchAllPricing(),
    );
  }

  Future<double> calculateFare({
    required String travelClass,
    required double distance,
  }) async {
    final res = await _repo.calculateFare(
      travelClass: travelClass,
      distance: distance,
    );

    return res.match(
      (failure) => 0.0,
      (fare) => fare,
    );
  }
}
