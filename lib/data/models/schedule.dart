class Schedule {
  final String id;
  final String trainId;
  final String trainName;
  final String routeId;
  final String departureTime;
  final String days;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Schedule({
    required this.id,
    required this.trainId,
    required this.trainName,
    required this.routeId,
    required this.departureTime,
    required this.days,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainId': trainId,
      'trainName': trainName,
      'routeId': routeId,
      'departureTime': departureTime,
      'days': days,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      trainId: json['trainId'] as String,
      trainName: json['trainName'] as String,
      routeId: json['routeId'] as String,
      departureTime: json['departureTime'] as String,
      days: json['days'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
