import 'package:flutter/material.dart';
import '../../../data/models/train.dart';

class AddTrainDialog extends StatefulWidget {
  final Train? train;
  final Future<void> Function(String, String, String, List<String>) onSave;

  const AddTrainDialog({super.key, this.train, required this.onSave});

  @override
  State<AddTrainDialog> createState() => _AddTrainDialogState();
}

class _AddTrainDialogState extends State<AddTrainDialog> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _typeController = TextEditingController();
  final List<String> _selectedClasses = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.train != null) {
      _nameController.text = widget.train!.name;
      _numberController.text = widget.train!.number;
      _typeController.text = widget.train!.type;
      _selectedClasses.addAll(widget.train!.availableClasses);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty ||
        _numberController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _selectedClasses.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(
        _nameController.text,
        _numberController.text,
        _typeController.text,
        List.from(_selectedClasses),
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
      title: Text(widget.train == null ? 'Add Train' : 'Edit Train'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Train Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Train Number'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Train Type'),
            ),
            const SizedBox(height: 16),
            const Text('Available Classes'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Sleeper', '3rd AC', '2nd AC', '1st AC', 'Chair Car']
                  .map((cls) {
                    final isSelected = _selectedClasses.contains(cls);
                    return FilterChip(
                      label: Text(cls),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedClasses.add(cls);
                          } else {
                            _selectedClasses.remove(cls);
                          }
                        });
                      },
                    );
                  })
                  .toList(),
            ),
          ],
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
    _nameController.dispose();
    _numberController.dispose();
    _typeController.dispose();
    super.dispose();
  }
}
