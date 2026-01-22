import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/route.dart';
import '../../../data/repositories/admin_route_repository.dart';

// Helper class to represent a station extracted from routes
class StationData {
  final String name;
  final String code;

  StationData({required this.name, required this.code});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StationData &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          code == other.code;

  @override
  int get hashCode => name.hashCode ^ code.hashCode;
}

class StationAutocompleteField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final Function(StationData)? onStationSelected;

  const StationAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.onStationSelected,
  });

  @override
  State<StationAutocompleteField> createState() =>
      _StationAutocompleteFieldState();
}

class _StationAutocompleteFieldState extends State<StationAutocompleteField> {
  final AdminRouteRepository _routeRepository = AdminRouteRepository();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<StationData> _allStations = [];
  List<StationData> _filteredStations = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadAllStations();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  Future<void> _loadAllStations() async {
    final result = await _routeRepository.getAllRoutes();
    result.fold(
      (failure) {
        debugPrint('Failed to load routes: ${failure.message}');
      },
      (routes) {
        // Extract unique stations from routes
        final stationsSet = <String, StationData>{};

        for (var route in routes) {
          // Add source station (always include)
          if (route.source.isNotEmpty) {
            String sourceCode = route.source
                .substring(0, route.source.length > 4 ? 4 : route.source.length)
                .toUpperCase();

            // Try to find code from stops if available
            if (route.stops.isNotEmpty) {
              try {
                final sourceStop = route.stops.firstWhere(
                  (stop) =>
                      stop.stationName.toLowerCase() ==
                      route.source.toLowerCase(),
                );
                if (sourceStop.code.isNotEmpty) {
                  sourceCode = sourceStop.code;
                }
              } catch (e) {
                // Source not in stops, use generated code
              }
            }

            stationsSet[route.source.toLowerCase()] = StationData(
              name: route.source,
              code: sourceCode,
            );
          }

          // Add destination station (always include)
          if (route.destination.isNotEmpty) {
            String destCode = route.destination
                .substring(
                  0,
                  route.destination.length > 4 ? 4 : route.destination.length,
                )
                .toUpperCase();

            // Try to find code from stops if available
            if (route.stops.isNotEmpty) {
              try {
                final destStop = route.stops.lastWhere(
                  (stop) =>
                      stop.stationName.toLowerCase() ==
                      route.destination.toLowerCase(),
                );
                if (destStop.code.isNotEmpty) {
                  destCode = destStop.code;
                }
              } catch (e) {
                // Destination not in stops, use generated code
              }
            }

            stationsSet[route.destination.toLowerCase()] = StationData(
              name: route.destination,
              code: destCode,
            );
          }

          // Add all intermediate stops
          for (var stop in route.stops) {
            if (stop.stationName.isNotEmpty) {
              String code = stop.code.isNotEmpty
                  ? stop.code
                  : stop.stationName
                        .substring(
                          0,
                          stop.stationName.length > 4
                              ? 4
                              : stop.stationName.length,
                        )
                        .toUpperCase();

              stationsSet[stop.stationName.toLowerCase()] = StationData(
                name: stop.stationName,
                code: code,
              );
            }
          }
        }

        setState(() {
          _allStations = stationsSet.values.toList()
            ..sort((a, b) => a.name.compareTo(b.name));
        });

        debugPrint(
          '✅ Loaded ${_allStations.length} unique stations from ${routes.length} routes',
        );
        for (var station in _allStations) {
          debugPrint('   - ${station.name} (${station.code})');
        }
      },
    );
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();

    final query = widget.controller.text.trim();

    if (query.isEmpty) {
      _removeOverlay();
      setState(() {
        _filteredStations = [];
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchStations(query);
    });
  }

  Future<void> _searchStations(String query) async {
    if (query.isEmpty) return;
    if (!_focusNode.hasFocus) return; // Don't search if lost focus

    setState(() {
      _isLoading = true;
    });

    // Filter stations locally
    final localResults = _allStations.where((station) {
      final q = query.toLowerCase().trim();
      final name = station.name.toLowerCase().trim();
      final code = station.code.toLowerCase().trim();
      return name.contains(q) || code.contains(q);
    }).toList();

    setState(() {
      _filteredStations = localResults;
      _isLoading = false;
    });

    if (_focusNode.hasFocus) {
      _showOverlay();
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _removeOverlay();
        }
      });
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              shadowColor: Colors.blue.withValues(alpha: 0.2),
              child: _buildDropdown(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildDropdown() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Searching stations...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_filteredStations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 8),
            Text(
              'No stations found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _filteredStations.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final station = _filteredStations[index];
          return InkWell(
            onTap: () => _selectStation(station),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            station.code,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectStation(StationData station) {
    _debounceTimer?.cancel();

    // Remove listener to prevent triggering search on text update
    widget.controller.removeListener(_onTextChanged);

    setState(() {
      widget.controller.text = station.name;
      // Clear suggestions immediately to ensure overlay doesn't have data to show
      _filteredStations = [];
    });

    // Re-add listener
    widget.controller.addListener(_onTextChanged);

    // Explicitly remove overlay and unfocus
    _removeOverlay();
    _focusNode.unfocus();

    widget.onStationSelected?.call(station);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                ),
                prefixIcon: Icon(widget.icon, color: Colors.blue.shade600),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () {
                          widget.controller.clear();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
