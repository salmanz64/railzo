class Route {
  final String id;
  final String source;
  final String destination;
  final List<RouteStop> stops;
  final int durationMinutes;
  final double distance;

  Route({
    required this.id,
    required this.source,
    required this.destination,
    required this.stops,
    required this.durationMinutes,
    required this.distance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'destination': destination,
      'stops': stops.map((s) => s.toJson()).toList(),
      'durationMinutes': durationMinutes,
      'distance': distance,
    };
  }

  factory Route.fromJson(Map<String, dynamic> json) {
    final stopsList = json['stops'];
    List<RouteStop> parsedStops = [];
    
    if (stopsList is List) {
      for (var item in stopsList) {
        if (item is Map<String, dynamic>) {
          try {
            parsedStops.add(RouteStop.fromJson(item));
          } catch (e) {
            // Skip invalid stops silently
          }
        }
      }
    }
    
    return Route(
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      stops: parsedStops,
      durationMinutes: json['durationMinutes']?.toInt() ?? 0,
      distance: json['distance']?.toDouble() ?? 0.0,
    );
  }
}

class RouteStop {
  final String stationName;
  final String code;
  final int arrivalTimeMinutes;
  final int departureTimeMinutes;
  final int haltMinutes;

  RouteStop({
    required this.stationName,
    required this.code,
    required this.arrivalTimeMinutes,
    required this.departureTimeMinutes,
    required this.haltMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'stationName': stationName,
      'code': code,
      'arrivalTimeMinutes': arrivalTimeMinutes,
      'departureTimeMinutes': departureTimeMinutes,
      'haltMinutes': haltMinutes,
    };
  }

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      stationName: json['stationName']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      arrivalTimeMinutes: json['arrivalTimeMinutes']?.toInt() ?? 0,
      departureTimeMinutes: json['departureTimeMinutes']?.toInt() ?? 0,
      haltMinutes: json['haltMinutes']?.toInt() ?? 0,
    );
  }
}
