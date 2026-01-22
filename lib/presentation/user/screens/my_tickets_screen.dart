import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../data/models/booking.dart';
import '../../../data/repositories/booking_repository.dart';

class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen> {
  bool _isLoading = true;
  List<Booking> _bookings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    final result = await ref
        .read(bookingRepositoryProvider)
        .getBookingsByUserId(userId: userId);

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        },
        (bookings) {
          setState(() {
            _bookings = bookings;
            _bookings.sort(
              (a, b) => b.bookingDate.compareTo(a.bookingDate),
            ); // Sort by newest
            _isLoading = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'My Tickets',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchBookings();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.airplane_ticket_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(_bookings[index]);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/user/ticket-details',
            arguments: booking,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.trainName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(booking.status),
                    backgroundColor: booking.status == 'Confirmed'
                        ? const Color(0xFF2196F3).withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: booking.status == 'Confirmed'
                          ? const Color(0xFF2196F3)
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'PNR: ${booking.pnr}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Travel Class',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        // Text(booking.travelClass, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // To/From info is not in Booking model currently without fetching Route.
                        // We can just show Date and Seats for now.
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(booking.journeyDate),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Seats: ${booking.selectedSeats.join(', ')}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (booking.status == 'Confirmed') const SizedBox(height: 12),
              if (booking.status == 'Confirmed')
                OutlinedButton(
                  onPressed: () => _showCancelDialog(context, booking),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Cancel Booking'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel booking ${booking.pnr}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          Consumer(
            builder: (context, ref, child) {
              return TextButton(
                onPressed: () async {
                  // Pop dialog first
                  Navigator.of(context).pop();

                  // Optimistic update or just cancel and refresh
                  final result = await ref
                      .read(bookingRepositoryProvider)
                      .cancelBooking(id: booking.id);

                  if (context.mounted) {
                    result.fold(
                      (failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cancellation failed: ${failure.message}',
                            ),
                          ),
                        );
                      },
                      (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Booking ${booking.pnr} cancelled successfully',
                            ),
                          ),
                        );
                        _fetchBookings(); // Refresh list
                      },
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Yes, Cancel'),
              );
            },
          ),
        ],
      ),
    );
  }
}
