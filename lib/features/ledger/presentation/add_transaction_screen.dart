import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/ledger_repository.dart';
import 'ledger_screen.dart'; // to invalidate provider
import '../../../core/widgets/animated_farm_background.dart';
import '../../../core/widgets/glass_container.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final dropdownBg = isDark ? const Color(0xFF16222F) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFCBD5E1);

    final categories = _type == 'Expense' ? _expenseCategories : _incomeCategories;
    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('New Transaction', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedFarmBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Expense', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                              value: 'Expense',
                              groupValue: _type,
                              activeColor: Colors.redAccent,
                              onChanged: (val) => setState(() => _type = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Income', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                              value: 'Income',
                              groupValue: _type,
                              activeColor: isDark ? Colors.greenAccent : Colors.green.shade700,
                              onChanged: (val) => setState(() => _type = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          labelText: 'Amount (Rs)',
                          labelStyle: TextStyle(color: subtextColor),
                          prefixText: 'Rs. ',
                          prefixStyle: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderCol)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
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
                        isExpanded: true,
                        dropdownColor: dropdownBg,
                        style: TextStyle(color: textColor, fontSize: 16),
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          labelText: 'Category',
                          labelStyle: TextStyle(color: subtextColor),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderCol)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
                        ),
                        items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)))).toList(),
                        onChanged: (val) => setState(() => _category = val!),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _descController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          labelText: 'Description (Optional)',
                          labelStyle: TextStyle(color: subtextColor),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderCol)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _type == 'Expense' ? Colors.redAccent : (isDark ? Colors.greenAccent.shade700 : Colors.green.shade700),
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
