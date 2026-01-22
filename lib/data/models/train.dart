import 'package:flutter/material.dart';

class Train {
  final String id;
  final String name;
  final String number;
  final String type;
  final List<String> availableClasses;

  Train({
    required this.id,
    required this.name,
    required this.number,
    required this.type,
    required this.availableClasses,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'type': type,
      'availableClasses': availableClasses,
    };
  }

  factory Train.fromJson(Map<String, dynamic> json) {
    return Train(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      number: json['number'] as String? ?? '',
      type: json['type'] as String? ?? 'Express',
      availableClasses: json['availableClasses'] != null
          ? List<String>.from(json['availableClasses'] as List)
          : <String>[],
    );
  }
}
