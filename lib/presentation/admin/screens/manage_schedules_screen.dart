import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/schedule.dart' as schedule_model;
import '../../../data/models/train.dart';
import '../../../data/models/route.dart' as route_model;
import '../viewmodels/schedule_view_model.dart';
import '../../../data/repositories/admin_train_repository.dart';
import '../../../data/repositories/admin_route_repository.dart';

class ManageSchedulesScreen extends ConsumerStatefulWidget {
  const ManageSchedulesScreen({super.key});

  @override
  ConsumerState<ManageSchedulesScreen> createState() =>
      _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends ConsumerState<ManageSchedulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleViewModelProvider.notifier).fetchAllSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(scheduleViewModelProvider);

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
                    'Manage Schedules',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  FloatingActionButton.small(
                    onPressed: () => _addSchedule(context, ref),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Expanded(
              child: schedulesAsync.when(
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading schedules...'),
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
                      const SizedBox(height: 16),
                      Text(
                        'Error: $error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(scheduleViewModelProvider.notifier)
                            .fetchAllSchedules(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (schedules) {
                  if (schedules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.schedule_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No schedules yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Click + to create your first schedule',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref
                          .read(scheduleViewModelProvider.notifier)
                          .fetchAllSchedules();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.train,
                                                color: Color(0xFF2196F3),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  schedule.trainName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.route,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 8),
                                              FutureBuilder<route_model.Route?>(
                                                future: ref
                                                    .read(
                                                      adminRouteRepositoryProvider,
                                                    )
                                                    .getAllRoutes()
                                                    .then(
                                                      (
                                                        result,
                                                      ) => result.getOrElse(
                                                        (failure) =>
                                                            <
                                                              route_model.Route
                                                            >[],
                                                      ),
                                                    )
                                                    .then((routes) {
                                                      try {
                                                        return routes
                                                            .firstWhere(
                                                              (r) =>
                                                                  r.id ==
                                                                  schedule
                                                                      .routeId,
                                                            );
                                                      } catch (_) {
                                                        return null;
                                                      }
                                                    }),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData &&
                                                      snapshot.data != null) {
                                                    final route =
                                                        snapshot.data!;
                                                    return Text(
                                                      '${route.source} → ${route.destination}',
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                      ),
                                                    );
                                                  }
                                                  return Text(
                                                    'Route: ${schedule.routeId}',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editSchedule(
                                            context,
                                            ref,
                                            schedule,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _deleteSchedule(
                                            context,
                                            ref,
                                            schedule,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      schedule.departureTime,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      schedule.days,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

  void _addSchedule(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    final trainsResult = await ref
        .read(adminTrainRepositoryProvider)
        .getAllTrains();
    final routesResult = await ref
        .read(adminRouteRepositoryProvider)
        .getAllRoutes();

    final trains = trainsResult.getOrElse((failure) => <Train>[]);
    final routes = routesResult.getOrElse((failure) => <route_model.Route>[]);

    if (!context.mounted) return;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _ScheduleDialog(
        trains: trains,
        routes: routes,
        onSave: (trainId, trainName, routeId, departureTime, days) async {
          await ref
              .read(scheduleViewModelProvider.notifier)
              .createSchedule(
                trainId: trainId,
                trainName: trainName,
                routeId: routeId,
                departureTime: departureTime,
                days: days,
              );
        },
      ),
    );
  }

  void _editSchedule(
    BuildContext context,
    WidgetRef ref,
    schedule_model.Schedule schedule,
  ) async {
    if (!context.mounted) return;

    final trainsResult = await ref
        .read(adminTrainRepositoryProvider)
        .getAllTrains();
    final routesResult = await ref
        .read(adminRouteRepositoryProvider)
        .getAllRoutes();

    final trains = trainsResult.getOrElse((failure) => <Train>[]);
    final routes = routesResult.getOrElse((failure) => <route_model.Route>[]);

    if (!context.mounted) return;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _ScheduleDialog(
        schedule: schedule,
        trains: trains,
        routes: routes,
        onSave: (trainId, trainName, routeId, departureTime, days) async {
          Navigator.of(context).pop();
          await ref
              .read(scheduleViewModelProvider.notifier)
              .updateSchedule(
                id: schedule.id,
                trainId: trainId,
                trainName: trainName,
                routeId: routeId,
                departureTime: departureTime,
                days: days,
              );
        },
      ),
    );
  }

  void _deleteSchedule(
    BuildContext context,
    WidgetRef ref,
    schedule_model.Schedule schedule,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text(
          'Are you sure you want to delete schedule for ${schedule.trainName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(scheduleViewModelProvider.notifier)
                  .deleteSchedule(schedule.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleDialog extends StatefulWidget {
  final schedule_model.Schedule? schedule;
  final List<Train> trains;
  final List<route_model.Route> routes;
  final Future<void> Function(
    String trainId,
    String trainName,
    String routeId,
    String departureTime,
    String days,
  )
  onSave;

  const _ScheduleDialog({
    this.schedule,
    required this.trains,
    required this.routes,
    required this.onSave,
  });

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  final _departureTimeController = TextEditingController();
  final _daysController = TextEditingController();
  String? _selectedTrainId;
  String? _selectedRouteId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _departureTimeController.text = widget.schedule!.departureTime;
      _daysController.text = widget.schedule!.days;
      // Only set IDs if they exist in the provided lists
      if (widget.trains.any((t) => t.id == widget.schedule!.trainId)) {
        _selectedTrainId = widget.schedule!.trainId;
      }
      if (widget.routes.any((r) => r.id == widget.schedule!.routeId)) {
        _selectedRouteId = widget.schedule!.routeId;
      }
    } else {
      _daysController.text = 'Daily';
    }
  }

  Future<void> _save() async {
    if (_selectedTrainId == null ||
        _selectedRouteId == null ||
        _departureTimeController.text.isEmpty ||
        _daysController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final train = widget.trains.firstWhere((t) => t.id == _selectedTrainId);
    final route = widget.routes.firstWhere((r) => r.id == _selectedRouteId);

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(
        train.id,
        train.name,
        route.id,
        _departureTimeController.text,
        _daysController.text,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.schedule == null ? 'Add Schedule' : 'Edit Schedule'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Train',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedTrainId,
                hint: const Text('Select a train'),
                isExpanded: true,
                items: widget.trains.map((train) {
                  return DropdownMenuItem(
                    value: train.id,
                    child: Text(
                      '${train.name} (#${train.number})',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTrainId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Route',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedRouteId,
                hint: const Text('Select a route'),
                isExpanded: true,
                items: widget.routes.map((route) {
                  return DropdownMenuItem(
                    value: route.id,
                    child: Text(
                      '${route.source} → ${route.destination}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRouteId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Departure Time (24-hour format)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _departureTimeController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 05:30',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Days of Operation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      'Daily',
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                      'Mon, Wed, Fri',
                      'Tue, Thu, Sat',
                      'Mon-Fri',
                      'Mon-Sat',
                    ].map((day) {
                      final isSelected = _daysController.text == day;
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _daysController.text = day;
                            } else {
                              _daysController.text = '';
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        _isSaving
            ? const CircularProgressIndicator()
            : FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  @override
  void dispose() {
    _departureTimeController.dispose();
    _daysController.dispose();
    super.dispose();
  }
}
