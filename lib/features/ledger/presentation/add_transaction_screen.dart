import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/ledger_repository.dart';
import 'ledger_screen.dart'; // to invalidate provider
import '../../../core/widgets/animated_farm_background.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Expense';
  String _category = 'Fertilizer';
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  final List<String> _expenseCategories = ['Seeds', 'Fertilizer', 'Pesticide', 'Labor', 'Equipment', 'Other'];
  final List<String> _incomeCategories = ['Harvest Sale', 'Subsidy', 'Other'];

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      await ref.read(ledgerRepositoryProvider).addEntry(
        amount: amount,
        type: _type,
        category: _category,
        date: DateTime.now(),
        description: _descController.text.isNotEmpty ? _descController.text : null,
      );
      ref.invalidate(ledgerEntriesProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Saved Successfully')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'Expense' ? _expenseCategories : _incomeCategories;
    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('New Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedFarmBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Expense', style: TextStyle(color: Colors.white)),
                              value: 'Expense',
                              groupValue: _type,
                              activeColor: Colors.redAccent,
                              onChanged: (val) => setState(() => _type = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Income', style: TextStyle(color: Colors.white)),
                              value: 'Income',
                              groupValue: _type,
                              activeColor: Colors.greenAccent,
                              onChanged: (val) => setState(() => _type = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          labelText: 'Amount (Rs)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixText: 'Rs. ',
                          prefixStyle: const TextStyle(color: Colors.white, fontSize: 24),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter amount';
                          if (double.tryParse(value) == null) return 'Enter valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        value: _category,
                        dropdownColor: Colors.grey.shade900,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                        ),
                        items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (val) => setState(() => _category = val!),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _descController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          labelText: 'Description (Optional)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _type == 'Expense' ? Colors.redAccent : Colors.greenAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Save Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
