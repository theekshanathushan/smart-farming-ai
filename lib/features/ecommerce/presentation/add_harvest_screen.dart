import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agri_ai/l10n/app_localizations.dart';
import '../../farm/presentation/farm_screen.dart';
import '../../market/data/market_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/marketplace_controller.dart';

class AddHarvestScreen extends ConsumerStatefulWidget {
  const AddHarvestScreen({super.key});

  @override
  ConsumerState<AddHarvestScreen> createState() => _AddHarvestScreenState();
}

class _AddHarvestScreenState extends ConsumerState<AddHarvestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cropNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _farmerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = 'Vegetables';
  String _unit = 'kg';
  String _grade = 'Grade A';
  String _district = 'Dambulla';
  DateTime _harvestDate = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _districts = [
    'Dambulla',
    'Matale',
    'Nuwara Eliya',
    'Kandy',
    'Badulla',
    'Kurunegala',
    'Anuradhapura',
    'Polonnaruwa',
    'Jaffna',
    'Puttalam',
    'Monaragala',
    'Hambantota',
    'Colombo / Pettah',
  ];

  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Spices',
    'Others',
  ];

  final List<String> _units = ['kg', 'bags', 'bunches', 'tons'];
  final List<String> _grades = ['Grade A', 'Grade B', 'Organic'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (auth.name != null && auth.name!.isNotEmpty) {
        _farmerNameController.text = auth.name!;
      }
      if (auth.phoneNumber != null && auth.phoneNumber!.isNotEmpty) {
        _phoneController.text = auth.phoneNumber!;
      }
    });
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _farmerNameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final qty = double.tryParse(_quantityController.text.trim()) ?? 0.0;
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

      await ref.read(marketplaceProvider.notifier).createListing(
        cropName: _cropNameController.text.trim(),
        category: _category,
        quantity: qty,
        unit: _unit,
        pricePerUnit: price,
        grade: _grade,
        harvestDate: _harvestDate,
        district: _district,
        farmerName: _farmerNameController.text.trim().isEmpty ? 'Local Farmer' : _farmerNameController.text.trim(),
        farmerPhone: _phoneController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.listingCreatedSuccess),
            backgroundColor: Colors.green.shade700,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red.shade800),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cropsAsync = ref.watch(cropsProvider);
    final marketPricesAsync = ref.watch(marketPricesProvider);

    // Find if there is a matching market price for suggestion
    String? marketSuggestion;
    final cropNameInput = _cropNameController.text.trim().toLowerCase();
    marketPricesAsync.whenData((prices) {
      for (final p in prices) {
        if (p.crop.toLowerCase().contains(cropNameInput) || cropNameInput.contains(p.crop.toLowerCase())) {
          marketSuggestion = p.retailPrice.toStringAsFixed(0);
          break;
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.addNewHarvest,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick autofill from registered crops
                cropsAsync.when(
                  data: (crops) {
                    if (crops.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 18, color: Colors.green.shade800),
                              const SizedBox(width: 8),
                              Text(
                                'Select from your farm crops:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: crops.map((c) {
                              return ActionChip(
                                label: Text(c.name, style: const TextStyle(fontSize: 12)),
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    _cropNameController.text = c.name;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Crop Name
                Text(l10n.cropName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _cropNameController,
                  decoration: InputDecoration(
                    hintText: l10n.cropNameHint,
                    prefixIcon: const Icon(Icons.eco, color: Colors.green),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? l10n.cropNameHint : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Category & Grade
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.filterCategory, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _category,
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.qualityGrade, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _grade,
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                            items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (v) => setState(() => _grade = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quantity & Unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.quantity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: 'e.g. 250',
                              prefixIcon: Icon(Icons.scale, color: Colors.black54),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enter quantity';
                              if (double.tryParse(v) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.unitLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _unit,
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                            items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (v) => setState(() => _unit = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price Per Unit
                Text(l10n.pricePerUnitLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'e.g. 180',
                    prefixIcon: const Icon(Icons.payments_outlined, color: Colors.green),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixText: 'LKR / $_unit',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter price';
                    if (double.tryParse(v) == null) return 'Invalid price';
                    return null;
                  },
                ),
                if (marketSuggestion != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.marketPriceSuggestion(marketSuggestion!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // District / Location
                Text(l10n.districtLocation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _district,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on, color: Colors.redAccent),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => _district = v!),
                ),
                const SizedBox(height: 16),

                // Farmer Name & Contact Phone
                Text(l10n.farmerInfo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _farmerNameController,
                  decoration: const InputDecoration(
                    hintText: 'Farmer Name',
                    prefixIcon: Icon(Icons.person, color: Colors.black54),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone, color: Colors.green),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? l10n.enterPhoneValidation : null,
                ),
                const SizedBox(height: 16),

                // Description (Optional)
                Text(l10n.descriptionOptional, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.descriptionHint,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          l10n.publishListing,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
