class Pricing {
  final String id;
  final String travelClass;
  final double basePricePerKm;
  final double serviceCharge;
  final double gst;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pricing({
    required this.id,
    required this.travelClass,
    required this.basePricePerKm,
    required this.serviceCharge,
    required this.gst,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'travelClass': travelClass,
      'basePricePerKm': basePricePerKm,
      'serviceCharge': serviceCharge,
      'gst': gst,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      id: json['id'] as String? ?? '',
      travelClass: json['travelClass'] as String,
      basePricePerKm: (json['basePricePerKm'] as num).toDouble(),
      serviceCharge: (json['serviceCharge'] as num).toDouble(),
      gst: (json['gst'] as num).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
