import 'package:flutter/material.dart';
import '../../../data/repositories/user_train_search_repository.dart';

class TrainDetailsScreen extends StatelessWidget {
  const TrainDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments as TrainSearchResult?;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Train Details')),
        body: const Center(child: Text('No train data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(result.train.name)),
      body: SingleChildScrollView(
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
                    Text(
                      result.train.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Train #${result.train.number}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.schedule),
                        const SizedBox(width: 8),
                        Text('Duration: ${result.duration}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.airline_seat_recline_normal),
                        const SizedBox(width: 8),
                        Text('${result.availableSeats} Seats Available'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.currency_rupee),
                        const SizedBox(width: 8),
                        Text('Fare: ${result.formattedPrice}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (result.route != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Route',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildRouteTimeline(result),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/user/seat-selection',
                  arguments: result,
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Select Seats'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteTimeline(TrainSearchResult result) {
    if (result.route == null || result.route!.stops.isEmpty) {
      return const Text(
        'No route information available',
        style: TextStyle(color: Colors.grey),
      );
    }

    final stops = result.route!.stops;

    return Column(
      children: List.generate(stops.length, (index) {
        final stop = stops[index];
        final isFirst = index == 0;
        final isLast = index == stops.length - 1;

        return Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isFirst || isLast) ? Colors.blue : Colors.grey,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.stationName,
                        style: TextStyle(
                          fontWeight: (isFirst || isLast)
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        '${stop.code} - ${_formatTime(stop.arrivalTimeMinutes)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isLast)
              Container(
                margin: const EdgeInsets.only(left: 5.5),
                height: 40,
                width: 1,
                color: Colors.grey,
              ),
          ],
        );
      }),
    );
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
}
