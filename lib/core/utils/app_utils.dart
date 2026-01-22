import 'package:intl/intl.dart';

class AppUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  static int calculatePrice(double basePrice, String travelClass, int passengers) {
    final multipliers = {
      'Sleeper': 1,
      '3rd AC': 2,
      '2nd AC': 3,
      '1st AC': 5,
    };
    return (basePrice * (multipliers[travelClass] ?? 1) * passengers).toInt();
  }
}
