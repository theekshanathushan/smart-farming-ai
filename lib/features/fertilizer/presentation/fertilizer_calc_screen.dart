import 'dart:ui';
import 'package:flutter/material.dart';
import '../domain/fertilizer_logic.dart';
import '../../../core/widgets/animated_farm_background.dart';

class FertilizerCalcScreen extends StatefulWidget {
  const FertilizerCalcScreen({super.key});

  @override
  State<FertilizerCalcScreen> createState() => _FertilizerCalcScreenState();
}

class _FertilizerCalcScreenState extends State<FertilizerCalcScreen> {
  String _selectedCrop = 'Paddy (වී)';
  final _areaController = TextEditingController(text: '1.0');
  Map<String, double>? _results;

  final List<String> _crops = ['Paddy (වී)', 'Corn (බඩඉරිඟු)', 'Tomato (තක්කාලි)'];

  void _calculate() {
    final acres = double.tryParse(_areaController.text) ?? 0.0;
    if (acres > 0) {
      setState(() {
        _results = FertilizerLogic.calculateFertilizer(_selectedCrop, acres);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid area in acres.')),
      );
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Fertilizer Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedFarmBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Select Crop', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCrop,
                          dropdownColor: Colors.grey.shade900,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          decoration: InputDecoration(
                            fillColor: Colors.transparent,
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                          ),
                          items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) => setState(() => _selectedCrop = val!),
                        ),
                        const SizedBox(height: 24),
                        const Text('Land Area (Acres)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _areaController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                          decoration: InputDecoration(
                            fillColor: Colors.transparent,
                            suffixText: 'Acres',
                            suffixStyle: const TextStyle(color: Colors.white70, fontSize: 16),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _calculate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Calculate Fertilizer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  if (_results != null) ...[
                    const SizedBox(height: 32),
                    const Text('Recommended Amounts', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ..._results!.entries.map((e) => _buildResultCard(e.key, e.value)),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String name, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.science, color: Colors.greenAccent),
              const SizedBox(width: 16),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Text('${amount.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
