import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/providers/locale_provider.dart';
import '../data/fertilizer_ai_service.dart';

class FertilizerCalcScreen extends ConsumerStatefulWidget {
  const FertilizerCalcScreen({super.key});

  @override
  ConsumerState<FertilizerCalcScreen> createState() => _FertilizerCalcScreenState();
}

class _FertilizerCalcScreenState extends ConsumerState<FertilizerCalcScreen> {
  String _selectedCrop = 'Paddy (වී)';
  bool _isCustomCrop = false;
  final _customCropController = TextEditingController();
  final _areaController = TextEditingController(text: '1.0');

  String _selectedStage = 'All Stages (සම්පූර්ණ චක්‍රය)';
  final List<String> _stages = [
    'All Stages (සම්පූර්ණ චක්‍රය)',
    'Basal / Planting (මූලික යෙදුම)',
    'Vegetative Growth (වර්ධන අවධිය)',
    'Flowering & Fruiting (මල්/ඵල අවධිය)',
  ];

  bool _isLoading = false;
  FertilizerPlanResult? _planResult;

  final List<String> _quickCrops = [
    'Paddy (වී)',
    'Corn (බඩඉරිඟු)',
    'Tomato (තක්කාලි)',
    'Chilli (මිරිස්)',
    'Big Onion (ලොකු ලූණු)',
    'Potato (අර්තාපල්)',
    'Carrot (කැරට්)',
    'Cabbage (ගෝවා)',
    'Brinjal (වම්බටු)',
    'Okra (බණ්ඩක්කා)',
    'Banana (කෙසෙල්)',
    'Papaya (පැපොල්)',
    'Beans (බෝංචි)',
    'Tea (තේ)',
    'Coconut (පොල්)',
    'Other / Custom Crop (වෙනත් බෝගයක්)',
  ];

  @override
  void dispose() {
    _customCropController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  String _getActiveCropName() {
    if (_isCustomCrop) {
      final text = _customCropController.text.trim();
      return text.isNotEmpty ? text : 'Custom Crop';
    }
    return _selectedCrop;
  }

  Future<void> _calculate() async {
    final acres = double.tryParse(_areaController.text) ?? 0.0;
    if (acres <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid land area in acres (e.g., 0.5, 1.0).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final cropName = _getActiveCropName();
    if (_isCustomCrop && _customCropController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the name of your crop.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final lang = ref.read(localeProvider).languageCode;
      final aiService = ref.read(fertilizerAiServiceProvider);

      final result = await aiService.getAiFertilizerPlan(
        cropName: cropName,
        acres: acres,
        language: lang,
        growthStage: _selectedStage.contains('All') ? null : _selectedStage,
      );

      if (mounted) {
        setState(() {
          _planResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calculation error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(localeProvider).languageCode;
    final isSi = currentLang == 'si';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          isSi ? 'පොහොර ගණකය (AI Fertilizer)' : 'Fertilizer Calculator',
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedFarmBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Banner
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 20,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.greenAccent, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSi ? 'ඕනෑම බෝගයකට AI පොහොර නිර්දේශ' : 'AI Crop Nutrition Engine',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isSi
                                    ? 'ඕනෑම බෝගයක් තෝරන්න හෝ නම ඇතුළත් කරන්න. නිශ්චිත N-P-K ප්‍රමාණ ක්ෂණිකව ගණනය වේ.'
                                    : 'Select or type any crop name. Calculates exact N-P-K & split application stages.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Input Form
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Crop Selection Header (Wrapped in Expanded to prevent any overflow)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isSi ? 'බෝගය තෝරන්න (Crop)' : 'Select Crop',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isCustomCrop = !_isCustomCrop;
                                });
                              },
                              icon: Icon(
                                _isCustomCrop ? Icons.list_alt : Icons.edit_note,
                                size: 16,
                                color: Colors.greenAccent,
                              ),
                              label: Text(
                                _isCustomCrop
                                    ? (isSi ? 'ලැයිස්තුව' : 'Preset List')
                                    : (isSi ? 'වෙනත් බෝගයක්' : 'Custom Crop'),
                                style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (!_isCustomCrop) ...[
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCrop,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1E281E),
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.greenAccent),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black.withValues(alpha: 0.25),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.greenAccent, width: 1.5),
                              ),
                            ),
                            items: _quickCrops
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        c,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: c.contains('Other') ? Colors.greenAccent : Colors.white,
                                          fontWeight: c.contains('Other') ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                if (val.contains('Other')) {
                                  setState(() {
                                    _isCustomCrop = true;
                                  });
                                } else {
                                  setState(() {
                                    _selectedCrop = val;
                                  });
                                }
                              }
                            },
                          ),
                        ] else ...[
                          // Custom Crop Name Input Field
                          TextFormField(
                            controller: _customCropController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            decoration: InputDecoration(
                              hintText: isSi
                                  ? 'උදා: කැරට්, බීට්රූට්, වැනිලා, ගස්ලබු...'
                                  : 'e.g., Bitter Gourd, Capsicum, Ginger, Betel...',
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                              filled: true,
                              fillColor: Colors.black.withValues(alpha: 0.3),
                              prefixIcon: const Icon(Icons.eco_outlined, color: Colors.greenAccent, size: 20),
                              suffixIcon: _customCropController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                                      onPressed: () {
                                        _customCropController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.greenAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.greenAccent, width: 1.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Quick suggestion custom chips (Dark styled, never white)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildQuickChip('Paddy (වී)'),
                              _buildQuickChip('Corn (බඩඉරිඟු)'),
                              _buildQuickChip('Tomato (තක්කාලි)'),
                              _buildQuickChip('Chilli (මිරිස්)'),
                              _buildQuickChip('Potato (අර්තාපල්)'),
                              _buildQuickChip('Banana (කෙසෙල්)'),
                              _buildQuickChip('Carrot (කැරට්)'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Land Area and Quick Sizes
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSi ? 'ඉඩම් ප්‍රමාණය (Area)' : 'Land Area (Acres)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _areaController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.black.withValues(alpha: 0.25),
                                      suffixText: isSi ? 'අක්කර' : 'Acres',
                                      suffixStyle: TextStyle(
                                        color: Colors.greenAccent.withValues(alpha: 0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.greenAccent, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Quick Acre Chips
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSi ? 'ක්ෂණික තේරීම්' : 'Quick Sizes',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _buildAcreChip('0.25'),
                                      _buildAcreChip('0.5'),
                                      _buildAcreChip('1.0'),
                                      _buildAcreChip('2.0'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Optional Growth Stage
                        Text(
                          isSi ? 'වර්ධන අවධිය (Growth Stage)' : 'Target Stage',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedStage,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E281E),
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.black.withValues(alpha: 0.2),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                          ),
                          items: _stages
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedStage = val);
                            }
                          },
                        ),

                        const SizedBox(height: 24),

                        // Calculate Button
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _calculate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                            elevation: 4,
                            shadowColor: Colors.greenAccent.withValues(alpha: 0.4),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(Icons.bolt, color: Colors.black, size: 22),
                          label: Text(
                            _isLoading
                                ? (isSi ? 'AI ගණනය කරමින් පවතී...' : 'AI Calculating...')
                                : (isSi ? 'AI මගින් පොහොර ගණනය කරන්න' : 'Calculate Fertilizer with AI'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Results Section
                  if (_planResult != null) ...[
                    const SizedBox(height: 28),
                    _buildResultsSection(context, _planResult!, isSi),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String crop) {
    final isSelected = !_isCustomCrop && _selectedCrop == crop;
    final label = crop.split(' ').first;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _isCustomCrop = false;
            _selectedCrop = crop;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.greenAccent
                : Colors.black.withValues(alpha: 0.35),
            border: Border.all(
              color: isSelected ? Colors.greenAccent : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check, size: 14, color: Colors.black),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcreChip(String val) {
    final isSelected = _areaController.text == val;
    return InkWell(
      onTap: () {
        setState(() {
          _areaController.text = val;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.07),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.white.withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$val Ac',
          style: TextStyle(
            color: isSelected ? Colors.greenAccent : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context, FertilizerPlanResult plan, bool isSi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Badge & Total Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isSi ? 'පොහොර නිර්දේශය' : 'Recommended Nutrition',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: plan.isAiGenerated
                    ? Colors.greenAccent.withValues(alpha: 0.2)
                    : Colors.amberAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: plan.isAiGenerated ? Colors.greenAccent : Colors.amberAccent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    plan.isAiGenerated ? Icons.auto_awesome : Icons.science_outlined,
                    size: 13,
                    color: plan.isAiGenerated ? Colors.greenAccent : Colors.amberAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    plan.isAiGenerated ? 'AI Custom' : 'Agronomic Baseline',
                    style: TextStyle(
                      color: plan.isAiGenerated ? Colors.greenAccent : Colors.amberAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total Chemical Fertilizer Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade900.withValues(alpha: 0.5),
                Colors.teal.shade900.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.cropName} (${plan.acres} Acres)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSi ? 'මුළු රසායනික පොහොර අවශ්‍යතාව' : 'Total Fertilizer Requirement',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${plan.totalChemicalKg.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Fertilizer Cards
        ...plan.fertilizers.map((f) => _buildFertilizerItemCard(f, isSi)),

        const SizedBox(height: 16),

        // Split Application Stages Timeline
        if (plan.applicationStages.isNotEmpty) ...[
          GlassContainer(
            padding: const EdgeInsets.all(18),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule_outlined, color: Colors.greenAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isSi ? 'පොහොර යෙදීමේ කාලසටහන' : 'Application Stages & Schedule',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...plan.applicationStages.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final stage = entry.value;
                  return _buildStageStep(idx + 1, stage, entry.key == plan.applicationStages.length - 1);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Organic Alternatives Card
        if (plan.organicAlternative.isNotEmpty) ...[
          GlassContainer(
            padding: const EdgeInsets.all(18),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco, color: Colors.lightGreenAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isSi ? 'කාබනික පොහොර නිර්දේශය' : 'Organic Compost & Manure',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  plan.organicAlternative,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Agronomy Pro Tips
        if (plan.practicalTips.isNotEmpty) ...[
          GlassContainer(
            padding: const EdgeInsets.all(18),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, color: Colors.amberAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isSi ? 'විශේෂ කෘෂි උපදෙස්' : 'Practical Application Tips',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  plan.practicalTips,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Ask AgriAI Button
        OutlinedButton.icon(
          onPressed: () {
            final prompt = isSi
                ? 'මම ${plan.cropName} සඳහා අක්කර ${plan.acres} කට පොහොර යෙදීමට බලාපොරොත්තු වෙමි. මෙම බෝගයේ වැඩි ඵලදාවක් ලබා ගැනීමට සහ පොහොර හානි වැළැක්වීමට අමතර උපදෙස් ලබා දෙන්න.'
                : 'I am cultivating ${plan.cropName} on ${plan.acres} acres. Could you provide detailed advice on optimal fertilizer schedule, soil preparation, and nutrient deficiency prevention?';
            context.push('/chat', extra: prompt);
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.greenAccent),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.greenAccent),
          label: Text(
            isSi ? 'මෙම බෝගය ගැන AgriAI ගෙන් වැඩිදුර අසන්න' : 'Ask AgriAI About This Crop',
            style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFertilizerItemCard(FertilizerItem item, bool isSi) {
    Color iconColor = Colors.greenAccent;
    if (item.nutrientType.contains('P')) {
      iconColor = Colors.lightBlueAccent;
    } else if (item.nutrientType.contains('K')) {
      iconColor = Colors.orangeAccent;
    }

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.science, color: iconColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.nutrientType.isNotEmpty)
                            Text(
                              item.nutrientType,
                              style: TextStyle(
                                color: iconColor.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${item.amountKg.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (item.timing.isNotEmpty || item.purpose.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
            const SizedBox(height: 8),
            if (item.timing.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13, color: Colors.white.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.timing,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            if (item.purpose.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 13, color: Colors.greenAccent.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.purpose,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStageStep(int stepNum, FertilizerStage stage, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.greenAccent,
              child: Text(
                '$stepNum',
                style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 45,
                color: Colors.greenAccent.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stage.stageName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (stage.timing.isNotEmpty)
                      Text(
                        stage.timing,
                        style: TextStyle(
                          color: Colors.greenAccent.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  stage.instructions,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
