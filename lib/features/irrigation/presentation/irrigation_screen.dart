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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final inputFill = isDark ? Colors.black.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.85);
    final inputBorder = isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1);
    final dropdownBg = isDark ? const Color(0xFF162232) : Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Smart Irrigation AI',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
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
                            Text(
                              'Select or Enter Crop',
                              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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
                            dropdownColor: dropdownBg,
                            isExpanded: true,
                            style: TextStyle(color: textColor, fontSize: 16),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: inputFill,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: inputBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: inputBorder),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            items: _popularCrops.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(c, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)),
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
                            style: TextStyle(color: textColor, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Type any crop (e.g. Dragon Fruit, Cassava, කෙසෙල්)...',
                              hintStyle: TextStyle(color: subtextColor.withValues(alpha: 0.7), fontSize: 14),
                              filled: true,
                              fillColor: inputFill,
                              prefixIcon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: inputBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: inputBorder),
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
                                  Text(
                                    'Land Area',
                                    style: TextStyle(color: textColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _areaController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: inputFill,
                                      prefixIcon: const Icon(Icons.landscape, color: Colors.blueAccent, size: 20),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: inputBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: inputBorder),
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
                                  Text(
                                    'Unit',
                                    style: TextStyle(color: textColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: _areaUnit,
                                    isExpanded: true,
                                    dropdownColor: dropdownBg,
                                    style: TextStyle(color: textColor, fontSize: 14),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: inputFill,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: inputBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: inputBorder),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    ),
                                    items: _areaUnits.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)))).toList(),
                                    onChanged: (val) => setState(() => _areaUnit = val!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Soil Type
                        Text(
                          'Soil Type (පස් වර්ගය)',
                          style: TextStyle(color: textColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSoil,
                          dropdownColor: dropdownBg,
                          isExpanded: true,
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: inputFill,
                            prefixIcon: const Icon(Icons.terrain, color: Colors.blueAccent, size: 20),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: inputBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: inputBorder),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: _soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)))).toList(),
                          onChanged: (val) => setState(() => _selectedSoil = val!),
                        ),

                        const SizedBox(height: 18),

                        // Climate Zone
                        Text(
                          'Climate Zone (කාලගුණ කලාපය)',
                          style: TextStyle(color: textColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedClimate,
                          dropdownColor: dropdownBg,
                          isExpanded: true,
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: inputFill,
                            prefixIcon: const Icon(Icons.wb_sunny_outlined, color: Colors.blueAccent, size: 20),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: inputBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: inputBorder),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: _climateZones.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)))).toList(),
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
                    const SizedBox(height: 24),

                    // Plan Title & Source Tag (Responsive row to prevent any overflow)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '${_getActiveCropName()} Irrigation Plan',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _results!.isAiGenerated
                                ? Colors.blueAccent.withValues(alpha: isDark ? 0.2 : 0.12)
                                : Colors.green.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _results!.isAiGenerated ? Colors.blueAccent : Colors.green,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _results!.isAiGenerated ? Icons.auto_awesome : Icons.check_circle_outline,
                                size: 13,
                                color: _results!.isAiGenerated ? Colors.blueAccent : (isDark ? Colors.greenAccent : Colors.green.shade700),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _results!.isAiGenerated ? 'AI Custom' : 'Scientific',
                                style: TextStyle(
                                  color: _results!.isAiGenerated ? Colors.blueAccent : (isDark ? Colors.greenAccent : Colors.green.shade700),
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
                      padding: const EdgeInsets.all(20),
                      borderRadius: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withValues(alpha: isDark ? 0.2 : 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.water_drop, color: Colors.blueAccent, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Daily Water Demand',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'දෛනික සමස්ත ජල අවශ්‍යතාවය',
                                      style: TextStyle(
                                        color: subtextColor,
                                        fontSize: 12.5,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Text(
                                '${_results!.dailyWaterLiters.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Liters / Day (ලීටර)',
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    _buildResultCard(
                      context,
                      'Recommended Method (නිර්දේශිත ක්‍රමය)',
                      _results!.recommendedMethod,
                      Icons.tune_rounded,
                      Colors.teal,
                    ),
                    const SizedBox(height: 12),
                    _buildResultCard(
                      context,
                      'Watering Frequency & Interval (වාර ගණන)',
                      _results!.frequency,
                      Icons.update_rounded,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildResultCard(
                      context,
                      'Growth Stage Schedule (අවධි අනුව සැලැස්ම)',
                      _results!.criticalGrowthStages,
                      Icons.eco_rounded,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildResultCard(
                      context,
                      'Water Conservation & Drought Tips (ජල සංරක්ෂණය)',
                      _results!.droughtAndSoilTips,
                      Icons.shield_outlined,
                      Colors.amber.shade700,
                    ),

                    const SizedBox(height: 20),

                    // Chat with AI Action
                    FilledButton.icon(
                      onPressed: _chatWithAgriAi,
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                      label: const Text(
                        'Chat with AgriAI about this Irrigation Plan',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blueAccent.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
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

  Widget _buildResultCard(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final valueColor = isDark ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF334155);

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14.5,
              height: 1.55,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
