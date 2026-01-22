import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/user_train_search_repository.dart'; // For TrainSearchResult
import '../../../data/repositories/booking_repository.dart';

class SeatSelectionScreen extends ConsumerStatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  ConsumerState<SeatSelectionScreen> createState() =>
      _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends ConsumerState<SeatSelectionScreen> {
  final Set<String> _selectedSeats = {};
  String _selectedCoach = 'B1';
  bool _isLoading = true;
  Set<String> _reservedSeats = {}; // Format: "B1-12"

  @override
  void initState() {
    super.initState();
    // Fetch seats after build frame or in init if we have args?
    // Args are in context, accessible in didChangeDependencies or build.
    // We'll trigger fetch in didChangeDependencies just once.
  }

  bool _initDone = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initDone) {
      final result =
          ModalRoute.of(context)?.settings.arguments as TrainSearchResult?;
      if (result != null) {
        _fetchReservedSeats(result.train.id, result.date);
      }
      _initDone = true;
    }
  }

  Future<void> _fetchReservedSeats(String trainId, DateTime date) async {
    debugPrint('Fetching reserved seats for Train: $trainId, Date: $date');
    final result = await ref
        .read(bookingRepositoryProvider)
        .getReservedSeats(trainId: trainId, journeyDate: date);

    if (mounted) {
      result.fold(
        (failure) {
          debugPrint('Failed to fetch seats: ${failure.message}');
          setState(() => _isLoading = false);
        },
        (seats) {
          debugPrint('Fetched ${seats.length} reserved seats: $seats');
          setState(() {
            _reservedSeats = seats.toSet();
            _isLoading = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments as TrainSearchResult?;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Seats')),
        body: const Center(child: Text('No train data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seats'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['B1', 'B2', 'B3'].map((coach) {
                  final isSelected = _selectedCoach == coach;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text('Coach $coach'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCoach = coach;
                          _selectedSeats.clear();
                        });
                      },
                      selectedColor: const Color(0xFF2196F3).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF2196F3),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildLegend(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildRealisticCoachLayout(),
                  ),
                ),
                _buildBottomBar(result),
              ],
            ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(const Color(0xFF2196F3), 'Available'),
          _legendItem(Colors.grey, 'Booked'),
          _legendItem(const Color(0xFF2196F3).withOpacity(0.7), 'Selected'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRealisticCoachLayout() {
    final coachData = _generateCoachData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Coach labels/Header if needed
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text("Upper Deck / Lower Deck View")),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: coachData.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(width: 8),
                      // Left Bay (3 seats)
                      Expanded(
                        flex: 3,
                        child: Column(children: row['left'] as List<Widget>),
                      ),
                      const SizedBox(width: 8),
                      // Right Bay (3 seats)
                      Expanded(
                        flex: 3,
                        child: Column(children: row['right'] as List<Widget>),
                      ),
                      const VerticalDivider(width: 20, thickness: 1),
                      // Side Berths (2 seats)
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: row['side'] as List<Widget>,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _generateCoachData() {
    final data = <Map<String, dynamic>>[];
    int seatNum = 1;

    // 4 compartments * 8 seats = 32 seats
    for (int row = 0; row < 4; row++) {
      final leftSeats = <Widget>[];
      final rightSeats = <Widget>[];
      final sideSeats = <Widget>[];

      // Left: 3 seats (LB, MB, UB) - simplified visualization
      for (int i = 0; i < 3; i++) {
        if (seatNum > 32) break;
        leftSeats.add(_buildSeatItem(seatNum));
        seatNum++;
      }

      // Right: 3 seats
      for (int i = 0; i < 3; i++) {
        if (seatNum > 32) break;
        rightSeats.add(_buildSeatItem(seatNum));
        seatNum++;
      }

      // Side: 2 seats (SL, SU)
      for (int i = 0; i < 2; i++) {
        if (seatNum > 32) break;
        sideSeats.add(_buildSeatItem(seatNum, isSide: true));
        seatNum++;
      }

      data.add({'left': leftSeats, 'right': rightSeats, 'side': sideSeats});
    }

    return data;
  }

  Widget _buildSeatItem(int seatNum, {bool isSide = false}) {
    final seatId = '$_selectedCoach-$seatNum';
    final isBooked = _reservedSeats.contains(seatId);
    final isSelected = _selectedSeats.contains(seatId); // Check full ID

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: isBooked ? null : () => _toggleSeat(seatNum),
        child: Container(
          height: isSide ? 40 : 35,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1976D2)
                : isBooked
                ? Colors.grey
                : const Color(0xFF42A5F5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1565C0)
                  : const Color(0xFF2196F3),
            ),
          ),
          child: Center(
            child: Text(
              '$seatNum',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(TrainSearchResult result) {
    // Extract price per seat from the result
    final pricePerSeat = result.price;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.event_seat,
                        color: Color(0xFF2196F3),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedSeats.length} Seats Selected',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Text(
                    '₹${_selectedSeats.length * pricePerSeat}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _selectedSeats.isNotEmpty
                  ? () => _proceedToPassengerDetails(result)
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: _selectedSeats.isNotEmpty
                    ? const Color(0xFF2196F3)
                    : Colors.grey,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Proceed'),
                  if (_selectedSeats.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSeat(int seatNum) {
    // We store full ID now to distinguish coaches
    // But since we clear selection on coach switch, we can just store ID.
    // However, logic ensures only current coach seats are visible/clickable.
    final seatId = '$_selectedCoach-$seatNum';

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        if (_selectedSeats.length < 6) {
          _selectedSeats.add(seatId);
        }
      }
    });
  }

  void _proceedToPassengerDetails(TrainSearchResult result) {
    final pricePerSeat = result.price;
    // Pass the actual formatted seat IDs
    final selectedSeatsList = _selectedSeats.toList();

    Navigator.pushNamed(
      context,
      '/user/passenger-details',
      arguments: {
        'result': result,
        'selectedSeats': selectedSeatsList,
        'totalAmount': selectedSeatsList.length * pricePerSeat,
      },
    );
  }
}
