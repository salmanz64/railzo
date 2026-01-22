import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/train.dart';
import '../viewmodels/train_view_model.dart';
import '../widgets/train_list_item.dart';
import '../widgets/add_train_dialog.dart';

class ManageTrainsScreen extends ConsumerStatefulWidget {
  const ManageTrainsScreen({super.key});

  @override
  ConsumerState<ManageTrainsScreen> createState() => _ManageTrainsScreenState();
}

class _ManageTrainsScreenState extends ConsumerState<ManageTrainsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trainViewModelProvider.notifier).fetchAllTrains();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainsAsync = ref.watch(trainViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Manage Trains',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  FloatingActionButton.small(
                    onPressed: () => _addTrain(context, ref),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Expanded(
              child: trainsAsync.when(
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading trains...'),
                    ],
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error: $error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(trainViewModelProvider.notifier)
                            .fetchAllTrains(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (trains) {
                  if (trains.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.train_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No trains yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Click + to add your first train',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref
                          .read(trainViewModelProvider.notifier)
                          .fetchAllTrains();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: trains.length,
                      itemBuilder: (context, index) {
                        final train = trains[index];
                        return TrainListItem(
                          train: train,
                          onEdit: () => _editTrain(context, ref, train),
                          onDelete: () => _deleteTrain(context, ref, train),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTrain(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddTrainDialog(
        onSave: (name, number, type, classes) async {
          ref
              .read(trainViewModelProvider.notifier)
              .createTrain(
                name: name,
                number: number,
                type: type,
                availableClasses: classes,
              );
        },
      ),
    );
  }

  void _editTrain(BuildContext context, WidgetRef ref, Train train) {
    showDialog(
      context: context,
      builder: (context) => AddTrainDialog(
        train: train,
        onSave: (name, number, type, classes) async {
          Navigator.of(context).pop();
          ref
              .read(trainViewModelProvider.notifier)
              .updateTrain(
                id: train.id,
                name: name,
                number: number,
                type: type,
                availableClasses: classes,
              );
        },
      ),
    );
  }

  void _deleteTrain(BuildContext context, WidgetRef ref, Train train) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Train'),
        content: Text('Are you sure you want to delete ${train.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(trainViewModelProvider.notifier).deleteTrain(train.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
