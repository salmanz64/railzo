class Seat {
  final String id;
  final String coachNumber;
  final int seatNumber;
  final String seatType;
  final SeatStatus status;
  final int row;
  final int column;

  Seat({
    required this.id,
    required this.coachNumber,
    required this.seatNumber,
    required this.seatType,
    required this.status,
    required this.row,
    required this.column,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coachNumber': coachNumber,
      'seatNumber': seatNumber,
      'seatType': seatType,
      'status': status.toString(),
      'row': row,
      'column': column,
    };
  }

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] as String,
      coachNumber: json['coachNumber'] as String,
      seatNumber: json['seatNumber'] as int,
      seatType: json['seatType'] as String,
      status: SeatStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => SeatStatus.available,
      ),
      row: json['row'] as int,
      column: json['column'] as int,
    );
  }
}

enum SeatStatus {
  available,
  booked,
  selected,
  reserved,
}
