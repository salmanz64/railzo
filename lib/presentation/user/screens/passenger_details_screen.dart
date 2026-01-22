import 'package:flutter/material.dart';
import '../../../data/models/passenger.dart';
import '../../../data/repositories/user_train_search_repository.dart';

class PassengerDetailsScreen extends StatefulWidget {
  const PassengerDetailsScreen({super.key});

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _nameControllers = <TextEditingController>[];
  final _ageControllers = <TextEditingController>[];
  final _selectedGenders = <String>[];
  bool _isInitialized = false;

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _ageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers(int count) {
    if (_isInitialized) return;

    for (int i = 0; i < count; i++) {
      _nameControllers.add(TextEditingController());
      _ageControllers.add(TextEditingController());
      _selectedGenders.add('Male');
    }
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final result = args?['result'] as TrainSearchResult?;
    final selectedSeats = args?['selectedSeats'] as List<String>? ?? [];
    final totalAmount = args?['totalAmount'] as int? ?? 0;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Passenger Details')),
        body: const Center(child: Text('No train data available')),
      );
    }

    _initializeControllers(selectedSeats.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Passenger Details')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      'Passengers: ${selectedSeats.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Seats: ${selectedSeats.join(", ")}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: selectedSeats.length,
              itemBuilder: (context, index) {
                return _buildPassengerCard(index, selectedSeats[index]);
              },
            ),
          ),
          _buildBottomBar(result, selectedSeats, totalAmount),
        ],
      ),
    );
  }

  Widget _buildPassengerCard(int index, String seatNumber) {
    if (index >= _nameControllers.length) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Passenger ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    'Seat $seatNumber',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameControllers[index],
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _ageControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _selectedGenders[index],
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.people_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: ['Male', 'Female', 'Other'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGenders[index] = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    TrainSearchResult result,
    List<String> selectedSeats,
    int totalAmount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Text(
                    '₹$totalAmount',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () =>
                    _proceedToReview(result, selectedSeats, totalAmount),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                label: const Text('Review Booking'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _proceedToReview(
    TrainSearchResult result,
    List<String> selectedSeats,
    int totalAmount,
  ) {
    // Validate all fields
    for (int i = 0; i < selectedSeats.length; i++) {
      final name = _nameControllers[i].text.trim();
      final age = _ageControllers[i].text.trim();

      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter name for Passenger ${i + 1}')),
        );
        return;
      }

      if (age.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter age for Passenger ${i + 1}')),
        );
        return;
      }

      if (int.tryParse(age) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter valid age for Passenger ${i + 1}'),
          ),
        );
        return;
      }
    }

    final passengers = List.generate(selectedSeats.length, (index) {
      return Passenger(
        id: 'p${DateTime.now().millisecondsSinceEpoch}_$index',
        name: _nameControllers[index].text.trim(),
        age: int.tryParse(_ageControllers[index].text) ?? 25,
        gender: _selectedGenders[index],
        berthPreference: null, // No preference needed since seats are selected
      );
    });

    Navigator.pushNamed(
      context,
      '/user/review-payment',
      arguments: {
        'result': result,
        'passengers': passengers,
        'selectedSeats': selectedSeats,
        'totalAmount': totalAmount,
      },
    );
  }
}
