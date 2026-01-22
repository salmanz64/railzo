class Passenger {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String? berthPreference;

  Passenger({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.berthPreference,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'berthPreference': berthPreference,
    };
  }

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      berthPreference: json['berthPreference'] as String?,
    );
  }
}
