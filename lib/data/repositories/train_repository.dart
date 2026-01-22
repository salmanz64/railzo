import '../models/train.dart';
import '../models/route.dart';
import '../models/seat.dart';

class TrainRepository {
  final List<Train> _trains = [
    Train(
      id: 't1',
      name: 'Rajdhani Express',
      number: '12951',
      type: 'Superfast',
      availableClasses: ['1st AC', '2nd AC', '3rd AC'],
    ),
    Train(
      id: 't2',
      name: 'Shatabdi Express',
      number: '12002',
      type: 'Superfast',
      availableClasses: ['3rd AC', 'Chair Car'],
    ),
    Train(
      id: 't3',
      name: 'Duronto Express',
      number: '12290',
      type: 'Premium',
      availableClasses: ['1st AC', '2nd AC', '3rd AC', 'Sleeper'],
    ),
    Train(
      id: 't4',
      name: 'Garib Rath',
      number: '12216',
      type: 'Express',
      availableClasses: ['3rd AC'],
    ),
    Train(
      id: 't5',
      name: 'Mail Express',
      number: '11028',
      type: 'Mail',
      availableClasses: ['Sleeper', '3rd AC', '2nd AC'],
    ),
  ];

  final List<Route> _routes = [
    Route(
      id: 'r1',
      source: 'Mumbai Central',
      destination: 'New Delhi',
      stops: [
        RouteStop(
          stationName: 'Mumbai Central',
          code: 'MMCT',
          arrivalTimeMinutes: 0,
          departureTimeMinutes: 0,
          haltMinutes: 0,
        ),
        RouteStop(
          stationName: 'Borivali',
          code: 'BVI',
          arrivalTimeMinutes: 30,
          departureTimeMinutes: 32,
          haltMinutes: 2,
        ),
        RouteStop(
          stationName: 'Surat',
          code: 'ST',
          arrivalTimeMinutes: 180,
          departureTimeMinutes: 185,
          haltMinutes: 5,
        ),
        RouteStop(
          stationName: 'Vadodara',
          code: 'BRC',
          arrivalTimeMinutes: 270,
          departureTimeMinutes: 275,
          haltMinutes: 5,
        ),
        RouteStop(
          stationName: 'Ratlam',
          code: 'RTM',
          arrivalTimeMinutes: 480,
          departureTimeMinutes: 485,
          haltMinutes: 5,
        ),
        RouteStop(
          stationName: 'Kota',
          code: 'KOTA',
          arrivalTimeMinutes: 720,
          departureTimeMinutes: 725,
          haltMinutes: 5,
        ),
        RouteStop(
          stationName: 'New Delhi',
          code: 'NDLS',
          arrivalTimeMinutes: 960,
          departureTimeMinutes: 960,
          haltMinutes: 0,
        ),
      ],
      durationMinutes: 960,
      distance: 1386.0,
    ),
    Route(
      id: 'r2',
      source: 'Chennai Central',
      destination: 'Bangalore City',
      stops: [
        RouteStop(
          stationName: 'Chennai Central',
          code: 'MAS',
          arrivalTimeMinutes: 0,
          departureTimeMinutes: 0,
          haltMinutes: 0,
        ),
        RouteStop(
          stationName: 'Arakkonam',
          code: 'AJJ',
          arrivalTimeMinutes: 70,
          departureTimeMinutes: 72,
          haltMinutes: 2,
        ),
        RouteStop(
          stationName: 'Katpadi',
          code: 'KPD',
          arrivalTimeMinutes: 135,
          departureTimeMinutes: 140,
          haltMinutes: 5,
        ),
        RouteStop(
          stationName: 'Bangarapet',
          code: 'BWT',
          arrivalTimeMinutes: 195,
          departureTimeMinutes: 197,
          haltMinutes: 2,
        ),
        RouteStop(
          stationName: 'Bangalore City',
          code: 'SBC',
          arrivalTimeMinutes: 270,
          departureTimeMinutes: 270,
          haltMinutes: 0,
        ),
      ],
      durationMinutes: 270,
      distance: 347.0,
    ),
    Route(
      id: 'r3',
      source: 'Kolkata',
      destination: 'Mumbai',
      stops: [
        RouteStop(
          stationName: 'Howrah',
          code: 'HWH',
          arrivalTimeMinutes: 0,
          departureTimeMinutes: 0,
          haltMinutes: 0,
        ),
        RouteStop(
          stationName: 'Dhanbad',
          code: 'DHN',
          arrivalTimeMinutes: 240,
          departureTimeMinutes: 245,
          haltMinutes: 5,
        ),
        RouteStop(
          stationName: 'Gaya',
          code: 'GAYA',
          arrivalTimeMinutes: 480,
          departureTimeMinutes: 485,
          haltMinutes: 5,
        ),
        RouteStop(
          stationName: 'Allahabad',
          code: 'ALD',
          arrivalTimeMinutes: 720,
          departureTimeMinutes: 730,
          haltMinutes: 10,
        ),
        RouteStop(
          stationName: 'Nagpur',
          code: 'NGP',
          arrivalTimeMinutes: 1020,
          departureTimeMinutes: 1030,
          haltMinutes: 10,
        ),
        RouteStop(
          stationName: 'Bhusaval',
          code: 'BSL',
          arrivalTimeMinutes: 1260,
          departureTimeMinutes: 1265,
          haltMinutes: 5,
        ),
        RouteStop(
          stationName: 'Mumbai CSMT',
          code: 'CSMT',
          arrivalTimeMinutes: 1440,
          departureTimeMinutes: 1440,
          haltMinutes: 0,
        ),
      ],
      durationMinutes: 1440,
      distance: 1968.0,
    ),
  ];

  List<Train> getAllTrains() {
    return List.from(_trains);
  }

  Train? getTrainById(String id) {
    try {
      return _trains.firstWhere((train) => train.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Route> getAllRoutes() {
    return List.from(_routes);
  }

  Route? getRouteById(String id) {
    try {
      return _routes.firstWhere((route) => route.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Train> searchTrains({
    required String from,
    required String to,
    required String travelClass,
  }) {
    final matchingRoutes = _routes.where((route) =>
        route.source.toLowerCase().contains(from.toLowerCase()) &&
        route.destination.toLowerCase().contains(to.toLowerCase())
    ).toList();

    return _trains.where((train) =>
        matchingRoutes.any((route) => true) &&
        train.availableClasses.contains(travelClass)
    ).toList();
  }

  List<Seat> getSeatsForCoach({
    required String trainId,
    required String coachNumber,
    required String travelClass,
    required DateTime journeyDate,
  }) {
    final seats = <Seat>[];
    final seatType = _getSeatTypeForClass(travelClass);
    final seatsPerRow = _getSeatsPerRow(travelClass);
    final rows = _getRowsPerCoach(travelClass);

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < seatsPerRow; col++) {
        final seatNumber = (row * seatsPerRow) + col + 1;
        final isBooked = (row * col) % 7 == 0 && (row + col) > 3;

        seats.add(Seat(
          id: '${coachNumber}_${seatNumber}',
          coachNumber: coachNumber,
          seatNumber: seatNumber,
          seatType: seatType,
          status: isBooked ? SeatStatus.booked : SeatStatus.available,
          row: row,
          column: col,
        ));
      }
    }

    return seats;
  }

  String _getSeatTypeForClass(String travelClass) {
    switch (travelClass) {
      case '1st AC':
        return 'Cabin';
      case '2nd AC':
        return 'Berth';
      case '3rd AC':
        return 'Berth';
      case 'Sleeper':
        return 'Berth';
      default:
        return 'Seat';
    }
  }

  int _getSeatsPerRow(String travelClass) {
    switch (travelClass) {
      case '1st AC':
        return 4;
      case '2nd AC':
        return 6;
      case '3rd AC':
        return 8;
      case 'Sleeper':
        return 8;
      default:
        return 5;
    }
  }

  int _getRowsPerCoach(String travelClass) {
    switch (travelClass) {
      case '1st AC':
        return 18;
      case '2nd AC':
        return 24;
      case '3rd AC':
        return 24;
      case 'Sleeper':
        return 24;
      default:
        return 20;
    }
  }

  Future<void> addTrain(Train train) async {
    _trains.add(train);
  }

  Future<void> updateTrain(Train train) async {
    final index = _trains.indexWhere((t) => t.id == train.id);
    if (index != -1) {
      _trains[index] = train;
    }
  }

  Future<void> deleteTrain(String id) async {
    _trains.removeWhere((t) => t.id == id);
  }

  Future<void> addRoute(Route route) async {
    _routes.add(route);
  }

  Future<void> updateRoute(Route route) async {
    final index = _routes.indexWhere((r) => r.id == route.id);
    if (index != -1) {
      _routes[index] = route;
    }
  }

  Future<void> deleteRoute(String id) async {
    _routes.removeWhere((r) => r.id == id);
  }
}
