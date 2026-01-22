import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/route.dart' as route_model;
import '../viewmodels/route_view_model.dart';

class ManageRoutesScreen extends ConsumerStatefulWidget {
  const ManageRoutesScreen({super.key});

  @override
  ConsumerState<ManageRoutesScreen> createState() => _ManageRoutesScreenState();
}

class _ManageRoutesScreenState extends ConsumerState<ManageRoutesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routeViewModelProvider.notifier).fetchAllRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(routeViewModelProvider);

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
                    'Manage Routes',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  FloatingActionButton.small(
                    onPressed: () => _addRoute(context, ref),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Expanded(
              child: routesAsync.when(
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading routes...'),
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
                        onPressed: () =>
                            ref.read(routeViewModelProvider.notifier).fetchAllRoutes(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (routes) {
                  if (routes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.route_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No routes yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Click + to add your first route',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.read(routeViewModelProvider.notifier).fetchAllRoutes();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: routes.length,
                      itemBuilder: (context, index) {
                        final route = routes[index];
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  color: Color(0xFF2196F3)),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  route.source,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  color: Colors.red),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  route.destination,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
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
                                          onPressed: () =>
                                              _editRoute(context, ref, route),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteRoute(context, ref, route),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.route,
                                        color: Colors.grey, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${route.stops.length} Stops',
                                      style:
                                          TextStyle(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.straighten,
                                        color: Colors.grey, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${route.distance.toStringAsFixed(1)} km',
                                      style:
                                          TextStyle(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.schedule,
                                        color: Colors.grey, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(route.durationMinutes / 60).toStringAsFixed(0)}h ${(route.durationMinutes % 60).toString().padLeft(2, '0')}m',
                                      style:
                                          TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                if (route.stops.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Stops:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  ...route.stops.take(3).map((stop) => Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8, top: 4),
                                        child: Row(
                                          children: [
                                            Icon(Icons.circle, size: 6, color: Colors.grey[600]),
                                            const SizedBox(width: 8),
                                            Text(stop.stationName),
                                            const SizedBox(width: 8),
                                            Text(
                                              '(${stop.code})',
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      )),
                                  if (route.stops.length > 3)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, top: 4),
                                      child: Text(
                                        '+${route.stops.length - 3} more stops',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                ],
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

  void _addRoute(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _RouteDialog(
        onSave: (source, destination, stops, duration, distance) async {
          await ref.read(routeViewModelProvider.notifier).createRoute(
                source: source,
                destination: destination,
                stops: stops,
                durationMinutes: duration,
                distance: distance,
              );
        },
      ),
    );
  }

  void _editRoute(BuildContext context, WidgetRef ref, route_model.Route route) {
    showDialog(
      context: context,
      builder: (context) => _RouteDialog(
        route: route,
        onSave: (source, destination, stops, duration, distance) async {
          Navigator.of(context).pop();
          await ref.read(routeViewModelProvider.notifier).updateRoute(
                id: route.id,
                source: source,
                destination: destination,
                stops: stops,
                durationMinutes: duration,
                distance: distance,
              );
        },
      ),
    );
  }

  void _deleteRoute(BuildContext context, WidgetRef ref, route_model.Route route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: Text(
            'Are you sure you want to delete ${route.source} to ${route.destination}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(routeViewModelProvider.notifier).deleteRoute(route.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _RouteDialog extends StatefulWidget {
  final route_model.Route? route;
  final Future<void> Function(
    String source,
    String destination,
    List<route_model.RouteStop> stops,
    int durationMinutes,
    double distance,
  ) onSave;

  const _RouteDialog({this.route, required this.onSave});

  @override
  State<_RouteDialog> createState() => _RouteDialogState();
}

class _RouteDialogState extends State<_RouteDialog> {
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final List<route_model.RouteStop> _stops = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.route != null) {
      _sourceController.text = widget.route!.source;
      _destinationController.text = widget.route!.destination;
      _durationController.text = widget.route!.durationMinutes.toString();
      _distanceController.text = widget.route!.distance.toString();
      _stops.addAll(widget.route!.stops);
    }
  }

  Future<void> _save() async {
    if (_sourceController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _distanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final duration = int.tryParse(_durationController.text);
    final distance = double.tryParse(_distanceController.text);

    if (duration == null || distance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid duration or distance')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(
        _sourceController.text,
        _destinationController.text,
        _stops,
        duration,
        distance,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _addStop() {
    showDialog(
      context: context,
      builder: (context) => _AddStopDialog(
        onAdd: (stationName, code, arrivalTime, departureTime, halt) {
          setState(() {
            _stops.add(route_model.RouteStop(
              stationName: stationName,
              code: code,
              arrivalTimeMinutes: arrivalTime,
              departureTimeMinutes: departureTime,
              haltMinutes: halt,
            ));
          });
        },
      ),
    );
  }

  void _editStop(int index, route_model.RouteStop stop) {
    showDialog(
      context: context,
      builder: (context) => _AddStopDialog(
        stop: stop,
        onAdd: (stationName, code, arrivalTime, departureTime, halt) {
          setState(() {
            _stops[index] = route_model.RouteStop(
              stationName: stationName,
              code: code,
              arrivalTimeMinutes: arrivalTime,
              departureTimeMinutes: departureTime,
              haltMinutes: halt,
            );
          });
        },
      ),
    );
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.route == null ? 'Add Route' : 'Edit Route'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _sourceController,
                decoration: const InputDecoration(labelText: 'Source Station'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _destinationController,
                decoration:
                    const InputDecoration(labelText: 'Destination Station'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        hintText: 'e.g., 960',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Distance (km)',
                        hintText: 'e.g., 1386',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Stops',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addStop,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Stop'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_stops.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No stops added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...List.generate(_stops.length, (index) {
                  final stop = _stops[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text('${index + 1}',
                            style: TextStyle(color: Colors.blue.shade900)),
                      ),
                      title: Text(stop.stationName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '(${stop.code})',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Arr: ${_formatTime(stop.arrivalTimeMinutes)} | '
                            'Dep: ${_formatTime(stop.departureTimeMinutes)} | '
                            'Halt: ${stop.haltMinutes} min',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _editStop(index, stop),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                size: 18, color: Colors.red),
                            onPressed: () => _removeStop(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
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
    _sourceController.dispose();
    _destinationController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }
}

class _AddStopDialog extends StatefulWidget {
  final route_model.RouteStop? stop;
  final void Function(
    String stationName,
    String code,
    int arrivalTime,
    int departureTime,
    int halt,
  ) onAdd;

  const _AddStopDialog({this.stop, required this.onAdd});

  @override
  State<_AddStopDialog> createState() => _AddStopDialogState();
}

class _AddStopDialogState extends State<_AddStopDialog> {
  final _stationNameController = TextEditingController();
  final _codeController = TextEditingController();
  final _arrivalHourController = TextEditingController();
  final _arrivalMinuteController = TextEditingController();
  final _departureHourController = TextEditingController();
  final _departureMinuteController = TextEditingController();
  final _haltController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.stop != null) {
      _stationNameController.text = widget.stop!.stationName;
      _codeController.text = widget.stop!.code;
      _arrivalHourController.text =
          (widget.stop!.arrivalTimeMinutes ~/ 60).toString();
      _arrivalMinuteController.text =
          (widget.stop!.arrivalTimeMinutes % 60).toString();
      _departureHourController.text =
          (widget.stop!.departureTimeMinutes ~/ 60).toString();
      _departureMinuteController.text =
          (widget.stop!.departureTimeMinutes % 60).toString();
      _haltController.text = widget.stop!.haltMinutes.toString();
    }
  }

  void _save() {
    final arrivalHour = int.tryParse(_arrivalHourController.text);
    final arrivalMinute = int.tryParse(_arrivalMinuteController.text);
    final departureHour = int.tryParse(_departureHourController.text);
    final departureMinute = int.tryParse(_departureMinuteController.text);
    final halt = int.tryParse(_haltController.text);

    if (arrivalHour == null ||
        arrivalMinute == null ||
        departureHour == null ||
        departureMinute == null ||
        halt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    final arrivalTime = arrivalHour * 60 + arrivalMinute;
    final departureTime = departureHour * 60 + departureMinute;

    widget.onAdd(
      _stationNameController.text,
      _codeController.text,
      arrivalTime,
      departureTime,
      halt,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.stop == null ? 'Add Stop' : 'Edit Stop'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _stationNameController,
              decoration: const InputDecoration(labelText: 'Station Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                  labelText: 'Station Code (e.g., BCT)'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _arrivalHourController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Arrival Hour',
                      hintText: 'e.g., 05',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _arrivalMinuteController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Arrival Min',
                      hintText: 'e.g., 30',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _departureHourController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Departure Hour',
                      hintText: 'e.g., 05',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _departureMinuteController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Departure Min',
                      hintText: 'e.g., 40',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _haltController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Halt Time (minutes)',
                hintText: 'e.g., 5',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  @override
  void dispose() {
    _stationNameController.dispose();
    _codeController.dispose();
    _arrivalHourController.dispose();
    _arrivalMinuteController.dispose();
    _departureHourController.dispose();
    _departureMinuteController.dispose();
    _haltController.dispose();
    super.dispose();
  }
}
