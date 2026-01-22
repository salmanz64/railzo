class DashboardStats {
  final int totalBookings;
  final int confirmedBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final List<TrainStats> popularTrains;
  final Map<String, int> classDistribution;

  DashboardStats({
    required this.totalBookings,
    required this.confirmedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.popularTrains,
    required this.classDistribution,
  });
}

class TrainStats {
  final String trainId;
  final String trainName;
  final int bookingCount;

  TrainStats({
    required this.trainId,
    required this.trainName,
    required this.bookingCount,
  });
}
