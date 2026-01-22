import 'package:flutter/material.dart';

class CoachLayoutEditorScreen extends StatelessWidget {
  const CoachLayoutEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Layout Editor'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Coach Configuration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildConfigCard('A1', '1st AC', '4x18', const Color(0xFF66FF00)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildConfigCard('A2', '2nd AC', '6x24', const Color(0xFF66FF00)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildConfigCard('B1', '3rd AC', '8x24', Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildConfigCard('S1', 'Sleeper', '8x24', Colors.purple),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Preview - 3rd AC Coach (B1)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSeatPreview(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard(String coach, String type, String layout, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(coach, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(type, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(layout, style: TextStyle(color: color, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _legendItem(const Color(0xFF66FF00), 'Available'),
                _legendItem(Colors.grey, 'Booked'),
                _legendItem(const Color(0xFF66FF00), 'Selected'),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(8, (row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    ...List.generate(4, (col) {
                      final seatNum = row * 8 + col + 1;
                      final isBooked = (row + col) % 5 == 0;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isBooked ? Colors.grey : const Color(0xFF66FF00),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '$seatNum',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 24),
                    ...List.generate(4, (col) {
                      final seatNum = row * 8 + col + 5;
                      final isBooked = (row + col) % 7 == 0;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isBooked ? Colors.grey : const Color(0xFF66FF00),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '$seatNum',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
