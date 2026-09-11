import 'package:flutter/material.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../../core/widgets/glass_container.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  String _selectedCrop = 'Paddy (වී)';
  final _areaController = TextEditingController(text: '1.0');
  Map<String, dynamic>? _results;

  final List<String> _crops = ['Paddy (වී)', 'Corn (බඩඉරිඟු)', 'Tomato (තක්කාලි)'];

  void _calculate() {
    final acres = double.tryParse(_areaController.text) ?? 0.0;
    if (acres > 0) {
      setState(() {
        _results = _getIrrigationLogic(_selectedCrop, acres);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid area in acres.')),
      );
    }
  }

  Map<String, dynamic> _getIrrigationLogic(String crop, double acres) {
    switch (crop) {
      case 'Paddy (වී)':
        return {
          'dailyWater': 20000.0 * acres, // Liters per day approximation
          'frequency': 'Continuous flooding (2-5cm depth)',
          'schedule': 'Maintain water level throughout vegetative stage.',
        };
      case 'Corn (බඩඉරිඟු)':
        return {
          'dailyWater': 6000.0 * acres,
          'frequency': 'Every 3-4 days',
          'schedule': 'Critical during silking and tasseling stages.',
        };
      case 'Tomato (තක්කාලි)':
        return {
          'dailyWater': 4000.0 * acres,
          'frequency': 'Daily or Every 2 days (Drip irrigation)',
          'schedule': 'Avoid overhead watering to prevent fungal diseases.',
        };
      default:
        return {
          'dailyWater': 5000.0 * acres,
          'frequency': 'Every 2 days',
          'schedule': 'Water early morning or late evening.',
        };
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
        title: const Text('Irrigation Management', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
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
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _calculate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Calculate Water Need', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  if (_results != null) ...[
                    const SizedBox(height: 32),
                    const Text('Irrigation Plan', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildResultCard('Daily Water Req.', '${(_results!['dailyWater'] as double).toStringAsFixed(0)} Liters', Icons.water_drop),
                    _buildResultCard('Frequency', _results!['frequency'], Icons.update),
                    _buildResultCard('Schedule & Tips', _results!['schedule'], Icons.lightbulb_outline),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
