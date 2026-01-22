import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/train.dart';
import '../../../data/repositories/admin_train_repository.dart';

class TrainAutocompleteField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final Function(Train)? onTrainSelected;

  const TrainAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.onTrainSelected,
  });

  @override
  State<TrainAutocompleteField> createState() => _TrainAutocompleteFieldState();
}

class _TrainAutocompleteFieldState extends State<TrainAutocompleteField> {
  final AdminTrainRepository _trainRepository = AdminTrainRepository();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Train> _allTrains = [];
  List<Train> _filteredTrains = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadAllTrains();
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

  Future<void> _loadAllTrains() async {
    final result = await _trainRepository.getAllTrains();
    result.fold(
      (failure) {
        debugPrint('Failed to load trains: ${failure.message}');
      },
      (trains) {
        setState(() {
          _allTrains = trains;
        });
      },
    );
  }

  void _onTextChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    final query = widget.controller.text.trim();

    // If text was cleared, hide dropdown
    if (query.isEmpty) {
      _removeOverlay();
      setState(() {
        _filteredTrains = [];
      });
      return;
    }

    // Debounce search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchTrains(query);
    });
  }

  Future<void> _searchTrains(String query) async {
    if (query.isEmpty) return;
    if (!_focusNode.hasFocus) return; // Don't search if lost focus

    setState(() {
      _isLoading = true;
    });

    // First try local filtering for instant results
    final localResults = _allTrains
        .where(
          (train) =>
              train.name.toLowerCase().contains(query.toLowerCase()) ||
              train.number.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    setState(() {
      _filteredTrains = localResults;
      _isLoading = false;
    });

    if (_focusNode.hasFocus) {
      _showOverlay();
    }

    // Then fetch from Firebase for up-to-date results
    final result = await _trainRepository.searchTrains(query: query);
    result.fold(
      (failure) {
        debugPrint('Search failed: ${failure.message}');
      },
      (trains) {
        if (mounted) {
          setState(() {
            _filteredTrains = trains;
            _isLoading = false;
          });
          _updateOverlay();
        }
      },
    );
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Delay removal to allow tap on dropdown item
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

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
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
              'Searching trains...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_filteredTrains.isEmpty) {
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
              'No trains found',
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
        itemCount: _filteredTrains.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final train = _filteredTrains[index];
          return InkWell(
            onTap: () => _selectTrain(train),
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
                      Icons.train_rounded,
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
                          train.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              train.number,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                train.type,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
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

  void _selectTrain(Train train) {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);

    setState(() {
      widget.controller.text = train.name;
    });

    widget.controller.addListener(_onTextChanged);
    _removeOverlay();
    _focusNode.unfocus();
    widget.onTrainSelected?.call(train);
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
