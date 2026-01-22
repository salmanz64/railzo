class Station {
  final String id;
  final String name;
  final String code;
  final String city;
  final String state;

  Station({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'city': city,
      'state': state,
    };
  }

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Station && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
