import 'package:fpdart/fpdart.dart';
import '../../core/failure/admin_failure.dart';
import '../../core/firebase/firestore_service.dart';
import '../models/station.dart';

class StationRepository {
  final FirestoreService _firestore = FirestoreService();
  static const String _collection = 'stations';

  Future<Either<AdminFailure, List<Station>>> getAllStations() async {
    return await _firestore.getCollection(
      collectionPath: _collection,
      fromJson: (data) => Station.fromJson(data),
    );
  }

  Future<Either<AdminFailure, List<Station>>> searchStations({
    required String query,
  }) async {
    final result = await getAllStations();

    return result.fold(
      (failure) => Left(failure),
      (stations) {
        final filtered = stations
            .where((station) =>
                station.name.toLowerCase().contains(query.toLowerCase()) ||
                station.code.toLowerCase().contains(query.toLowerCase()) ||
                station.city.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return Right(filtered);
      },
    );
  }

  Future<Either<AdminFailure, Station>> getStationById(String id) async {
    return await _firestore.getDocument(
      collectionPath: _collection,
      documentId: id,
      fromJson: (data) => Station.fromJson(data),
    );
  }

  Future<Either<AdminFailure, List<Station>>> seedDefaultStations() async {
    final defaultStations = [
      Station(
        id: 'st001',
        name: 'Mumbai Central',
        code: 'MMCT',
        city: 'Mumbai',
        state: 'Maharashtra',
      ),
      Station(
        id: 'st002',
        name: 'New Delhi',
        code: 'NDLS',
        city: 'Delhi',
        state: 'Delhi',
      ),
      Station(
        id: 'st003',
        name: 'Chennai Central',
        code: 'MAS',
        city: 'Chennai',
        state: 'Tamil Nadu',
      ),
      Station(
        id: 'st004',
        name: 'Bangalore City',
        code: 'SBC',
        city: 'Bangalore',
        state: 'Karnataka',
      ),
      Station(
        id: 'st005',
        name: 'Howrah',
        code: 'HWH',
        city: 'Kolkata',
        state: 'West Bengal',
      ),
      Station(
        id: 'st006',
        name: 'Hyderabad',
        code: 'HYD',
        city: 'Hyderabad',
        state: 'Telangana',
      ),
      Station(
        id: 'st007',
        name: 'Ahmedabad',
        code: 'ADI',
        city: 'Ahmedabad',
        state: 'Gujarat',
      ),
      Station(
        id: 'st008',
        name: 'Pune',
        code: 'PUNE',
        city: 'Pune',
        state: 'Maharashtra',
      ),
      Station(
        id: 'st009',
        name: 'Jaipur',
        code: 'JP',
        city: 'Jaipur',
        state: 'Rajasthan',
      ),
      Station(
        id: 'st010',
        name: 'Lucknow',
        code: 'LKO',
        city: 'Lucknow',
        state: 'Uttar Pradesh',
      ),
      Station(
        id: 'st011',
        name: 'Bhopal',
        code: 'BPL',
        city: 'Bhopal',
        state: 'Madhya Pradesh',
      ),
      Station(
        id: 'st012',
        name: 'Patna',
        code: 'PNBE',
        city: 'Patna',
        state: 'Bihar',
      ),
      Station(
        id: 'st013',
        name: 'Kanpur',
        code: 'CNB',
        city: 'Kanpur',
        state: 'Uttar Pradesh',
      ),
      Station(
        id: 'st014',
        name: 'Agra',
        code: 'AGC',
        city: 'Agra',
        state: 'Uttar Pradesh',
      ),
      Station(
        id: 'st015',
        name: 'Surat',
        code: 'ST',
        city: 'Surat',
        state: 'Gujarat',
      ),
      Station(
        id: 'st016',
        name: 'Vadodara',
        code: 'BRC',
        city: 'Vadodara',
        state: 'Gujarat',
      ),
      Station(
        id: 'st017',
        name: 'Nagpur',
        code: 'NGP',
        city: 'Nagpur',
        state: 'Maharashtra',
      ),
      Station(
        id: 'st018',
        name: 'Indore',
        code: 'INDB',
        city: 'Indore',
        state: 'Madhya Pradesh',
      ),
      Station(
        id: 'st019',
        name: 'Thane',
        code: 'TNA',
        city: 'Thane',
        state: 'Maharashtra',
      ),
      Station(
        id: 'st020',
        name: 'Bhopal',
        code: 'BPL',
        city: 'Bhopal',
        state: 'Madhya Pradesh',
      ),
    ];

    for (var station in defaultStations) {
      await _firestore.addDocument(
        collectionPath: _collection,
        data: station.toJson(),
      );
    }

    return Right(defaultStations);
  }
}
