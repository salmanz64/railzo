import 'package:flutter/material.dart';
import '../../../data/models/train.dart';

class TrainListItem extends StatelessWidget {
  final Train train;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TrainListItem({
    super.key,
    required this.train,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        train.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '#${train.number}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text(train.type)),
                ...train.availableClasses.map((cls) => Chip(label: Text(cls))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
