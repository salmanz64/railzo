import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:railzo/data/models/passenger.dart';
import 'package:railzo/data/repositories/user_train_search_repository.dart';
import 'package:railzo/data/repositories/booking_repository.dart';
import 'package:railzo/core/services/stripe_service.dart';

class ReviewPaymentScreen extends ConsumerWidget {
  const ReviewPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final result = args?['result'] as TrainSearchResult?;
    final passengers = args?['passengers'] as List? ?? [];
    final selectedSeats = args?['selectedSeats'] as List<String>? ?? [];
    final totalAmount = args?['totalAmount'] as int? ?? 0;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review & Payment')),
        body: const Center(child: Text('No booking data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Review & Payment')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Journey Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            result.train.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '#${result.train.number}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.airline_seat_recline_normal),
                              const SizedBox(width: 8),
                              Text(selectedSeats.join(', ')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Passenger Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...passengers.map((p) {
                            final passenger = p is Passenger
                                ? p
                                : Passenger.fromJson(p as Map<String, dynamic>);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  const CircleAvatar(child: Icon(Icons.person)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          passenger.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${passenger.age} yrs, ${passenger.gender}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _paymentRow('Base Fare', (totalAmount * 0.9).toInt()),
                          _paymentRow('GST (5%)', (totalAmount * 0.05).toInt()),
                          _paymentRow('Service Charge', 30),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '₹${totalAmount + 30}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: FilledButton(
                onPressed: () => _processPayment(
                  context,
                  ref,
                  result,
                  passengers,
                  selectedSeats,
                  (totalAmount + 30).toDouble(),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text('Pay ₹${totalAmount + 30}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text('₹$amount')],
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    WidgetRef ref,
    TrainSearchResult result,
    List<dynamic> passengers,
    List<String> selectedSeats,
    double totalAmount,
  ) async {
    // 1. Stripe Payment Flow
    final stripeSuccess = await StripeService.instance.makePayment(
      amount: totalAmount,
      currency: 'INR',
      context: context,
    );

    if (!stripeSuccess) return;

    // 2. Original Booking Logic
    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';
    final pnr =
        'PNR${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}';

    // Convert passengers to Map if they are objects
    final passengerList = passengers.map((p) {
      if (p is Passenger) {
        return p.toJson();
      }
      return p as Map<String, dynamic>;
    }).toList();

    final bookingResult = await ref
        .read(bookingRepositoryProvider)
        .createBooking(
          pnr: pnr,
          trainId: result.train.id,
          trainName: result.train.name,
          routeId: result.route?.id ?? 'unknown_route',
          travelClass: result.travelClass,
          selectedSeats: selectedSeats,
          passengers: passengerList,
          totalAmount: totalAmount,
          journeyDate: result.date.toIso8601String(),
          userId: userId,
        );

    if (context.mounted) {
      Navigator.of(context).pop(); // Dismiss loading

      bookingResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking failed: ${failure.message}')),
          );
        },
        (booking) {
          Navigator.pushNamed(context, '/user/booking-success');
        },
      );
    }
  }
}
