import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/viewmodels/pricing_view_model.dart';
import '../../../data/models/pricing.dart';

class PricingManagementScreen extends ConsumerStatefulWidget {
  const PricingManagementScreen({super.key});

  @override
  ConsumerState<PricingManagementScreen> createState() => _PricingManagementScreenState();
}

class _PricingManagementScreenState extends ConsumerState<PricingManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pricingViewModelProvider.notifier).fetchAllPricing();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pricingState = ref.watch(pricingViewModelProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewPricing(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Pricing Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: pricingState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (pricingList) {
                  if (pricingList.isEmpty) {
                    return const Center(child: Text('No pricing data available'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: pricingList.length,
                    itemBuilder: (context, index) {
                      final price = pricingList[index];
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
                                  Text(price.travelClass,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editPricing(price),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deletePricing(price),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(),
                              const SizedBox(height: 12),
                              _priceRow('Base Price per Km', '₹${price.basePricePerKm}'),
                              _priceRow('Service Charge', '₹${price.serviceCharge}'),
                              _priceRow('GST', '${price.gst}%'),
                              const SizedBox(height: 12),
                              _calculateFareExample(price),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _calculateFareExample(Pricing price) {
    final distance = 1386.0;
    final basePrice = distance * price.basePricePerKm;
    final serviceCharge = price.serviceCharge;
    final gst = (basePrice + serviceCharge) * (price.gst / 100);
    final total = basePrice + serviceCharge + gst;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Example Fare for ${distance.toInt()} km',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Fare'),
              Text('₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
            ],
          ),
        ],
      ),
    );
  }

  void _editPricing(Pricing price) {
    showDialog(
      context: context,
      builder: (context) => _PricingDialog(
        pricing: price,
        onSave: (updatedPricing) async {
          await ref.read(pricingViewModelProvider.notifier).updatePricing(
                id: updatedPricing.id,
                travelClass: updatedPricing.travelClass,
                basePricePerKm: updatedPricing.basePricePerKm,
                serviceCharge: updatedPricing.serviceCharge,
                gst: updatedPricing.gst,
              );
          
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pricing updated successfully')),
            );
          }
        },
      ),
    );
  }

  void _addNewPricing() {
    showDialog(
      context: context,
      builder: (context) => _PricingDialog(
        isCreating: true,
        pricing: Pricing(
          id: '',
          travelClass: '',
          basePricePerKm: 0.0,
          serviceCharge: 0.0,
          gst: 0.0,
        ),
        onSave: (newPricing) async {
          if (newPricing.travelClass.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a travel class name')),
              );
            }
            return;
          }

          await ref.read(pricingViewModelProvider.notifier).createPricing(
                travelClass: newPricing.travelClass,
                basePricePerKm: newPricing.basePricePerKm,
                serviceCharge: newPricing.serviceCharge,
                gst: newPricing.gst,
              );
          
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pricing created successfully')),
            );
          }
        },
      ),
    );
  }

  void _deletePricing(Pricing price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pricing'),
        content: Text('Are you sure you want to delete pricing for ${price.travelClass}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(pricingViewModelProvider.notifier).deletePricing(id: price.id);
              
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pricing deleted successfully')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PricingDialog extends StatefulWidget {
  final Pricing pricing;
  final Function(Pricing) onSave;
  final bool isCreating;

  const _PricingDialog({
    required this.pricing, 
    required this.onSave,
    this.isCreating = false,
  });

  @override
  State<_PricingDialog> createState() => _PricingDialogState();
}

class _PricingDialogState extends State<_PricingDialog> {
  final _classController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _serviceChargeController = TextEditingController();
  final _gstController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _classController.text = widget.pricing.travelClass;
    _basePriceController.text = widget.pricing.basePricePerKm.toString();
    _serviceChargeController.text = widget.pricing.serviceCharge.toString();
    _gstController.text = widget.pricing.gst.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isCreating ? 'Add New Pricing' : 'Edit ${widget.pricing.travelClass} Pricing'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isCreating)
            TextField(
              controller: _classController,
              decoration: const InputDecoration(labelText: 'Travel Class'),
              enabled: widget.isCreating,
            ),
          TextField(
            controller: _basePriceController,
            decoration: const InputDecoration(labelText: 'Base Price per Km'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          TextField(
            controller: _serviceChargeController,
            decoration: const InputDecoration(labelText: 'Service Charge'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          TextField(
            controller: _gstController,
            decoration: const InputDecoration(labelText: 'GST (%)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _savePricing,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _savePricing() {
    final updatedPricing = Pricing(
      id: widget.pricing.id,
      travelClass: widget.isCreating ? _classController.text : widget.pricing.travelClass,
      basePricePerKm: double.tryParse(_basePriceController.text) ?? 0,
      serviceCharge: double.tryParse(_serviceChargeController.text) ?? 0,
      gst: double.tryParse(_gstController.text) ?? 0,
    );
    widget.onSave(updatedPricing);
  }
}
