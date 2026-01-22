class Booking {
  final String id;
  final String pnr;
  final String trainId;
  final String trainName;
  final String routeId;
  final String travelClass;
  final List<String> selectedSeats;
  final List<Map<String, dynamic>> passengers;
  final double totalAmount;
  final DateTime journeyDate;
  final String status;
  final DateTime bookingDate;
  final String userId;

  Booking({
    required this.id,
    required this.pnr,
    required this.trainId,
    required this.trainName,
    required this.routeId,
    required this.travelClass,
    required this.selectedSeats,
    required this.passengers,
    required this.totalAmount,
    required this.journeyDate,
    required this.status,
    required this.bookingDate,
    required this.userId,
  });

  Booking copyWith({
    String? id,
    String? pnr,
    String? trainId,
    String? trainName,
    String? routeId,
    String? travelClass,
    List<String>? selectedSeats,
    List<Map<String, dynamic>>? passengers,
    double? totalAmount,
    DateTime? journeyDate,
    String? status,
    DateTime? bookingDate,
    String? userId,
  }) {
    return Booking(
      id: id ?? this.id,
      pnr: pnr ?? this.pnr,
      trainId: trainId ?? this.trainId,
      trainName: trainName ?? this.trainName,
      routeId: routeId ?? this.routeId,
      travelClass: travelClass ?? this.travelClass,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      passengers: passengers ?? this.passengers,
      totalAmount: totalAmount ?? this.totalAmount,
      journeyDate: journeyDate ?? this.journeyDate,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pnr': pnr,
      'trainId': trainId,
      'trainName': trainName,
      'routeId': routeId,
      'travelClass': travelClass,
      'selectedSeats': selectedSeats,
      'passengers': passengers,
      'totalAmount': totalAmount,
      'journeyDate': journeyDate.toIso8601String(),
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
      'userId': userId,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      return Booking(
        id: json['id'] as String? ?? '',
        pnr: json['pnr'] as String? ?? 'UNKNOWN',
        trainId: json['trainId'] as String? ?? '',
        trainName: json['trainName'] as String? ?? 'Unknown Train',
        routeId: json['routeId'] as String? ?? '',
        travelClass: json['travelClass'] as String? ?? 'Standard',
        selectedSeats:
            (json['selectedSeats'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        passengers:
            (json['passengers'] as List?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [],
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        journeyDate:
            DateTime.tryParse(json['journeyDate']?.toString() ?? '') ??
            DateTime.now(),
        status: json['status'] as String? ?? 'Pending',
        bookingDate:
            DateTime.tryParse(json['bookingDate']?.toString() ?? '') ??
            DateTime.now(),
        userId: json['userId'] as String? ?? '',
      );
    } catch (e, stack) {
      print('❌ Booking.fromJson Failed!');
      print('   JSON Data: $json');
      print('   Error: $e');
      print('   Stack: $stack');
      rethrow;
    }
  }
}
