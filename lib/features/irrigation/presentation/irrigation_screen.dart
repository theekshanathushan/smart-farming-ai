import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/irrigation_ai_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../../core/widgets/glass_container.dart';

class IrrigationScreen extends ConsumerStatefulWidget {
  const IrrigationScreen({super.key});

  @override
  ConsumerState<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends ConsumerState<IrrigationScreen> {
  String _selectedCrop = 'Paddy (වී)';
  final _customCropController = TextEditingController();
  final _areaController = TextEditingController(text: '1.0');
  String _areaUnit = 'Acres';
  String _selectedSoil = 'Loamy / සාරවත් මැටි මිශ්‍ර පස';
  String _selectedClimate = 'Dry Zone (වියළි කලාපය - Yala)';

  bool _isCustomCrop = false;
  bool _isLoadingAi = false;
  IrrigationPlanResult? _results;

  final List<String> _popularCrops = [
    'Paddy (වී)',
    'Corn (බඩඉරිඟු)',
    'Tomato (තක්කාලි)',
    'Chilli (මිරිස්)',
    'Big Onion (රතු / ලොකු ලූනු)',
    'Potato (අර්තාපල්)',
    'Carrot (කැරට්)',
    'Cabbage (ගෝවා)',
    'Eggplant / Brinjal (වම්බටු)',
    'Okra / Ladies Finger (බණ්ඩක්කා)',
    'Banana (කෙසෙල්)',
    'Papaya (පැපොල්)',
    'Watermelon (පැණි කොමඩු)',
    'Cucumber (පිපිඤ්ඤා)',
    'Pumpkin (වට්ටක්කා)',
    'Coconut (පොල්)',
    'Tea (තේ)',
    'Pepper (ගම්මිරිස්)',
    'Custom / Enter Other Crop...',
  ];

  final List<String> _areaUnits = ['Acres', 'Hectares', 'Perches'];

  final List<String> _soilTypes = [
    'Loamy / සාරවත් මැටි මිශ්‍ර පස',
    'Sandy / වැලි සහිත පස (ඉක්මනින් ජලය බසින)',
    'Clay / මැටි අධික පස (ජලය රඳන)',
  ];

  final List<String> _climateZones = [
    'Dry Zone (වියළි කලාපය - Yala)',
    'Wet Zone (තෙත් කලාපය - Maha)',
    'Intermediate Zone (අතරමැදි කලාපය)',
  ];

  @override
  void dispose() {
    _customCropController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  String _getActiveCropName() {
    if (_isCustomCrop) {
      return _customCropController.text.trim();
    }
    return _selectedCrop;
  }

  double _getAreaInAcres() {
    final rawArea = double.tryParse(_areaController.text) ?? 0.0;
    if (_areaUnit == 'Hectares') {
      return rawArea * 2.47105;
    } else if (_areaUnit == 'Perches') {
      return rawArea / 160.0;
    }
    return rawArea;
  }

  Future<void> _calculateAndSearchAi() async {
    final cropName = _getActiveCropName();
    if (cropName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a crop name.')),
      );
      return;
    }

    final acres = _getAreaInAcres();
    if (acres <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid land area.')),
      );
      return;
    }

    setState(() {
      _isLoadingAi = true;
    });

    final currentLang = ref.read(localeProvider).languageCode;
    final aiService = ref.read(irrigationAiServiceProvider);

    try {
      final plan = await aiService.getAiIrrigationPlan(
        cropName: cropName,
        acres: acres,
        soilType: _selectedSoil,
        climateZone: _selectedClimate,
        language: currentLang,
      );

      if (mounted) {
        setState(() {
          _results = plan;
          _isLoadingAi = false;
        });
      }
    } catch (e) {
      // Fallback to offline scientific baseline
      final fallbackPlan = aiService.calculateOfflineBaseline(
        cropName: cropName,
        acres: acres,
        soilType: _selectedSoil,
        climateZone: _selectedClimate,
      );
      if (mounted) {
        setState(() {
          _results = fallbackPlan;
          _isLoadingAi = false;
        });
      }
    }
  }

  void _chatWithAgriAi() {
    if (_results == null) return;
    final crop = _getActiveCropName();
    final currentLang = ref.read(localeProvider).languageCode;
    final rawArea = _areaController.text;

    String prompt;
    if (currentLang == 'si') {
      prompt = 'මගේ $crop වගාවේ ජල කළමනාකරණ සැලසුම පහත දැක්වේ:\n\n'
          '• බෝගය: $crop\n'
          '• ඉඩම් ප්‍රමාණය: $rawArea $_areaUnit (${_getAreaInAcres().toStringAsFixed(2)} Acres)\n'
          '• දෛනික ජල අවශ්‍යතාව: ${_results!.dailyWaterLiters.toStringAsFixed(0)} Liters/day\n'
          '• නිර්දේශිත ක්‍රමය: ${_results!.recommendedMethod}\n'
          '• ජලය යෙදීමේ වාර ගණන: ${_results!.frequency}\n'
          '• පස: $_selectedSoil\n'
          '• කලාපය: $_selectedClimate\n\n'
          'කරුණාකර මෙම බෝගයේ ජල සම්පාදනය, නියං සමයේ පස තෙතමනය රඳවා ගැනීමේ ක්‍රම සහ බිංදු ජල පද්ධතියක් සැලසුම් කරන ආකාරය පිළිබඳව උපදෙස් කරුණු වශයෙන් පැහැදිලි කරන්න.';
    } else {
      prompt = 'Here is the irrigation plan for my $crop field:\n\n'
          '• Crop: $crop\n'
          '• Area: $rawArea $_areaUnit (${_getAreaInAcres().toStringAsFixed(2)} Acres)\n'
          '• Daily Water Requirement: ${_results!.dailyWaterLiters.toStringAsFixed(0)} Liters/day\n'
          '• Irrigation Method: ${_results!.recommendedMethod}\n'
          '• Frequency: ${_results!.frequency}\n'
          '• Soil: $_selectedSoil\n'
          '• Climate: $_selectedClimate\n\n'
          'Please provide detailed agronomic recommendations on drip system setup, water conservation, and soil moisture monitoring.';
    }

    context.push('/chat', extra: prompt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Smart Irrigation AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedFarmBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Card
                  GlassContainer(
                    padding: const EdgeInsets.all(22),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Crop Selection Header
                        Row(
                          children: [
                            const Icon(Icons.grass, color: Colors.blueAccent, size: 20),
                            const SizedBox(width: 8),
                            const Text('Select or Enter Crop', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (_isCustomCrop)
                              TextButton(
                                onPressed: () => setState(() => _isCustomCrop = false),
                                child: const Text('Preset List', style: TextStyle(color: Colors.blueAccent)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (!_isCustomCrop) ...[
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCrop,
                              dropdownColor: const Color(0xFF16222F),
                              isExpanded: true,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.08),
                                border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            items: _popularCrops.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(c, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == 'Custom / Enter Other Crop...') {
                                setState(() {
                                  _isCustomCrop = true;
                                });
                              } else if (val != null) {
                                setState(() {
                                  _selectedCrop = val;
                                });
                              }
                            },
                          ),
                        ] else ...[
                          TextFormField(
                            controller: _customCropController,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Type any crop (e.g. Dragon Fruit, Cassava, කෙසෙල්)...',
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.08),
                              prefixIcon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // Land Area and Unit
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Land Area', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _areaController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white.withValues(alpha: 0.08),
                                      prefixIcon: const Icon(Icons.landscape, color: Colors.blueAccent, size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Unit', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: _areaUnit,
                                    dropdownColor: const Color(0xFF16222F),
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white.withValues(alpha: 0.08),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: _areaUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                    onChanged: (val) => setState(() => _areaUnit = val!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Soil Type
                        const Text('Soil Type (පස් වර්ගය)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSoil,
                          dropdownColor: const Color(0xFF16222F),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.08),
                            prefixIcon: const Icon(Icons.terrain, color: Colors.blueAccent, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: _soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) => setState(() => _selectedSoil = val!),
                        ),

                        const SizedBox(height: 18),

                        // Climate Zone
                        const Text('Climate Zone (කාලගුණ කලාපය)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedClimate,
                          dropdownColor: const Color(0xFF16222F),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.08),
                            prefixIcon: const Icon(Icons.wb_sunny_outlined, color: Colors.blueAccent, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: _climateZones.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) => setState(() => _selectedClimate = val!),
                        ),

                        const SizedBox(height: 26),

                        // Action Button
                        ElevatedButton.icon(
                          onPressed: _isLoadingAi ? null : _calculateAndSearchAi,
                          icon: _isLoadingAi
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.water_drop_rounded, size: 22),
                          label: Text(
                            _isLoadingAi ? 'Consulting Smart AI Engine...' : 'Calculate & Search with AI',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Results Display
                  if (_results != null) ...[
                    const SizedBox(height: 28),

                    // Plan Title & Source Tag
                    Row(
                      children: [
                        Text(
                          '${_getActiveCropName()} Irrigation Plan',
                          style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _results!.isAiGenerated ? Colors.blueAccent.withValues(alpha: 0.25) : Colors.greenAccent.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _results!.isAiGenerated ? Colors.blueAccent : Colors.greenAccent),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_results!.isAiGenerated ? Icons.auto_awesome : Icons.check_circle_outline, size: 14, color: _results!.isAiGenerated ? Colors.blueAccent : Colors.greenAccent),
                              const SizedBox(width: 4),
                              Text(
                                _results!.isAiGenerated ? 'AI Custom Model' : 'Scientific Baseline',
                                style: TextStyle(
                                  color: _results!.isAiGenerated ? Colors.blueAccent : Colors.greenAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Primary Water Requirement Hero Card
                    GlassContainer(
                      padding: const EdgeInsets.all(22),
                      borderRadius: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.water, color: Colors.blueAccent, size: 28),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Daily Water Demand', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                    Text('දෛනික සමස්ත ජල අවශ්‍යතාවය', style: TextStyle(color: Colors.white38, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${_results!.dailyWaterLiters.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ',
                                style: const TextStyle(color: Colors.blueAccent, fontSize: 34, fontWeight: FontWeight.bold),
                              ),
                              const Text('Liters / Day (ලීටර)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    _buildResultCard('Recommended Method (නිර්දේශිත ක්‍රමය)', _results!.recommendedMethod, Icons.tune_rounded, Colors.tealAccent),
                    const SizedBox(height: 12),
                    _buildResultCard('Watering Frequency & Interval (වාර ගණන)', _results!.frequency, Icons.update_rounded, Colors.orangeAccent),
                    const SizedBox(height: 12),
                    _buildResultCard('Growth Stage Schedule (අවධි අනුව සැලැස්ම)', _results!.criticalGrowthStages, Icons.eco_rounded, Colors.greenAccent),
                    const SizedBox(height: 12),
                    _buildResultCard('Water Conservation & Drought Tips (ජල සංරක්ෂණය)', _results!.droughtAndSoilTips, Icons.shield_outlined, Colors.amberAccent),

                    const SizedBox(height: 20),

                    // Chat with AI Action
                    FilledButton.icon(
                      onPressed: _chatWithAgriAi,
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text('Chat with AgriAI about this Irrigation Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blueAccent.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color iconColor) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45),
          ),
        ],
      ),
    );
  }
}
