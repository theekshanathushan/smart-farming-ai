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
  String _selectedCrop = 'Paddy';
  bool _isCustomCrop = false;
  final _customCropController = TextEditingController();
  final _areaController = TextEditingController(text: '1.0');

  String _selectedStage = 'All Stages';
  static const List<Map<String, String>> _stageOptions = [
    {'key': 'All Stages', 'en': 'All Stages (Complete Lifecycle)', 'si': 'සම්පූර්ණ චක්‍රය', 'ta': 'முழு பயிர் பருவம்'},
    {'key': 'Basal', 'en': 'Basal (At Planting)', 'si': 'මූලික යෙදුම', 'ta': 'ஆரம்ப உரமிடல்'},
    {'key': 'Vegetative', 'en': 'Vegetative Growth Stage', 'si': 'වර්ධන අවධිය', 'ta': 'வளர்ச்சி பருவம்'},
    {'key': 'Flowering', 'en': 'Flowering & Fruiting Stage', 'si': 'මල් සහ ඵල අවධිය', 'ta': 'பூக்கும் மற்றும் காய் பிடிக்கும் பருவம்'},
  ];

  bool _isLoading = false;
  FertilizerPlanResult? _planResult;

  static const List<Map<String, String>> _fertilizerCrops = [
    {'key': 'Paddy', 'en': 'Paddy', 'si': 'වී', 'ta': 'நெல்'},
    {'key': 'Corn', 'en': 'Corn', 'si': 'බඩඉරිඟු', 'ta': 'மக்காச்சோளம்'},
    {'key': 'Tomato', 'en': 'Tomato', 'si': 'තක්කාලි', 'ta': 'தக்காளி'},
    {'key': 'Chilli', 'en': 'Chilli', 'si': 'මිරිස්', 'ta': 'மிளகாய்'},
    {'key': 'Big Onion', 'en': 'Big Onion', 'si': 'ලොකු ලූනු', 'ta': 'பெரிய வெங்காயம்'},
    {'key': 'Potato', 'en': 'Potato', 'si': 'අර්තාපල්', 'ta': 'உருளைக்கிழங்கு'},
    {'key': 'Carrot', 'en': 'Carrot', 'si': 'කැරට්', 'ta': 'கேரட்'},
    {'key': 'Cabbage', 'en': 'Cabbage', 'si': 'ගෝවා', 'ta': 'முட்டைக்கோஸ்'},
    {'key': 'Brinjal', 'en': 'Brinjal', 'si': 'වම්බටු', 'ta': 'கத்தரிக்காய்'},
    {'key': 'Okra', 'en': 'Okra', 'si': 'බණ්ඩක්කා', 'ta': 'வெண்டைக்காய்'},
    {'key': 'Banana', 'en': 'Banana', 'si': 'කෙසෙල්', 'ta': 'வாழை'},
    {'key': 'Papaya', 'en': 'Papaya', 'si': 'පැපොල්', 'ta': 'பப்பாளி'},
    {'key': 'Beans', 'en': 'Beans', 'si': 'බෝංචි', 'ta': 'பீன்ஸ்'},
    {'key': 'Tea', 'en': 'Tea', 'si': 'තේ', 'ta': 'தேயிலை'},
    {'key': 'Coconut', 'en': 'Coconut', 'si': 'පොල්', 'ta': 'தென்னை'},
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
    final isTa = currentLang == 'ta';

    String appTitle = 'Fertilizer Calculator';
    String bannerTitle = 'AI Crop Nutrition Engine';
    String bannerDesc = 'Select or type any crop name. Calculates exact N-P-K & split application stages.';
    String selectCropLabel = 'Select Crop';
    String presetBtn = 'Preset List';
    String customBtn = 'Custom Crop';
    String customHint = 'e.g., Bitter Gourd, Capsicum, Ginger, Betel...';
    String landAreaLabel = 'Land Area';
    String acreSuffix = 'Acres';
    String quickSizesLabel = 'Quick Sizes';
    String stageLabel = 'Target Growth Stage';
    String calcBtnText = _isLoading ? 'AI Calculating...' : 'Calculate Fertilizer with AI';

    if (isSi) {
      appTitle = 'පොහොර ගණකය';
      bannerTitle = 'ඕනෑම බෝගයකට AI පොහොර නිර්දේශ';
      bannerDesc = 'ඕනෑම බෝගයක් තෝරන්න හෝ නම ඇතුළත් කරන්න. නිශ්චිත N-P-K ප්‍රමාණ ක්ෂණිකව ගණනය වේ.';
      selectCropLabel = 'බෝගය තෝරන්න';
      presetBtn = 'ලැයිස්තුව';
      customBtn = 'වෙනත් බෝගයක්';
      customHint = 'උදා: කැරට්, බීට්රූට්, වැනිලා, ගස්ලබු...';
      landAreaLabel = 'ඉඩම් ප්‍රමාණය';
      acreSuffix = 'අක්කර';
      quickSizesLabel = 'ක්ෂණික තේරීම්';
      stageLabel = 'වර්ධන අවධිය';
      calcBtnText = _isLoading ? 'AI ගණනය කරමින් පවතී...' : 'AI මගින් පොහොර ගණනය කරන්න';
    } else if (isTa) {
      appTitle = 'உரக் கால்குலேட்டர்';
      bannerTitle = 'AI பயிர் ஊட்டச்சத்து வழிகாட்டி';
      bannerDesc = 'பயிர் பெயரைத் தேர்ந்தெடுக்கவும் அல்லது தட்டச்சு செய்யவும். துல்லியமான N-P-K அளவுகள் கணக்கிடப்படும்.';
      selectCropLabel = 'பயிரைத் தேர்ந்தெடுக்கவும்';
      presetBtn = 'பட்டியல்';
      customBtn = 'மற்ற பயிர்';
      customHint = 'எ.கா. பாகற்காய், மிளகாய், இஞ்சி...';
      landAreaLabel = 'நிலப் பரப்பு';
      acreSuffix = 'ஏக்கர்';
      quickSizesLabel = 'விரைவு அளவுகள்';
      stageLabel = 'வளர்ச்சிப் பருவம்';
      calcBtnText = _isLoading ? 'AI கணக்கிடுகிறது...' : 'AI மூலம் உரத்தைக் கணக்கிடுக';
    }

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
          appTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          overflow: TextOverflow.ellipsis,
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
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bannerTitle,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                bannerDesc,
                                style: TextStyle(
                                  color: subtextColor,
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
                        // Crop Selection Header
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectCropLabel,
                                style: TextStyle(
                                  color: textColor,
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
                                color: theme.colorScheme.primary,
                              ),
                              label: Text(
                                _isCustomCrop ? presetBtn : customBtn,
                                style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
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
                            dropdownColor: dropdownBg,
                            style: TextStyle(color: textColor, fontSize: 15),
                            icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: inputFill,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: inputBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: inputBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                              ),
                            ),
                            items: _fertilizerCrops
                                .map((c) {
                                  final label = isSi ? c['si']! : (isTa ? c['ta']! : c['en']!);
                                  return DropdownMenuItem(
                                    value: c['key'],
                                    child: Text(
                                      label,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: textColor),
                                    ),
                                  );
                                })
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCrop = val;
                                });
                              }
                            },
                          ),
                        ] else ...[
                          // Custom Crop Name Input Field
                          TextFormField(
                            controller: _customCropController,
                            autofocus: true,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              hintText: customHint,
                              hintStyle: TextStyle(color: subtextColor.withValues(alpha: 0.7), fontSize: 13),
                              filled: true,
                              fillColor: inputFill,
                              prefixIcon: Icon(Icons.eco_outlined, color: theme.colorScheme.primary, size: 20),
                              suffixIcon: _customCropController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: subtextColor, size: 18),
                                      onPressed: () {
                                        _customCropController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: inputBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: inputBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Quick suggestion custom chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _fertilizerCrops.take(7).map((c) {
                              final label = isSi ? c['si']! : (isTa ? c['ta']! : c['en']!);
                              return _buildQuickChip(c['key']!, label, isDark, textColor, theme);
                            }).toList(),
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
                                    landAreaLabel,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _areaController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: inputFill,
                                      suffixText: acreSuffix,
                                      suffixStyle: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: inputBorder),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: inputBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
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
                                    quickSizesLabel,
                                    style: TextStyle(
                                      color: subtextColor,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _buildAcreChip('0.25', isDark, theme, subtextColor),
                                      _buildAcreChip('0.5', isDark, theme, subtextColor),
                                      _buildAcreChip('1.0', isDark, theme, subtextColor),
                                      _buildAcreChip('2.0', isDark, theme, subtextColor),
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
                          stageLabel,
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedStage,
                          isExpanded: true,
                          dropdownColor: dropdownBg,
                          style: TextStyle(color: textColor, fontSize: 13),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: inputFill,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: inputBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: inputBorder),
                            ),
                          ),
                          items: _stageOptions
                              .map((s) {
                                final label = isSi ? s['si']! : (isTa ? s['ta']! : s['en']!);
                                return DropdownMenuItem(
                                  value: s['key'],
                                  child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)),
                                );
                              })
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
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: isDark ? const Color(0xFF042F22) : Colors.white,
                            elevation: 3,
                            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.35),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: isDark ? const Color(0xFF042F22) : Colors.white,
                                  ),
                                )
                              : Icon(Icons.bolt, color: isDark ? const Color(0xFF042F22) : Colors.white, size: 22),
                          label: Text(
                            calcBtnText,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              color: isDark ? const Color(0xFF042F22) : Colors.white,
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
                    _buildResultsSection(context, _planResult!, currentLang, textColor, subtextColor, isDark, theme),
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

  Widget _buildQuickChip(String cropKey, String label, bool isDark, Color textColor, ThemeData theme) {
    final isSelected = !_isCustomCrop && _selectedCrop == cropKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _isCustomCrop = false;
            _selectedCrop = cropKey;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? Colors.black.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.85)),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1)),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(Icons.check, size: 14, color: isDark ? const Color(0xFF042F22) : Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? const Color(0xFF042F22) : Colors.white)
                      : textColor,
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

  Widget _buildAcreChip(String val, bool isDark, ThemeData theme, Color subtextColor) {
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
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : (isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.85)),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1)),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$val Ac',
          style: TextStyle(
            color: isSelected ? theme.colorScheme.primary : subtextColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context, FertilizerPlanResult plan, String lang, Color textColor, Color subtextColor, bool isDark, ThemeData theme) {
    final isSi = lang == 'si';
    final isTa = lang == 'ta';

    String sectionTitle = 'Recommended Nutrition';
    String baselineTag = isSi ? 'විද්‍යාත්මක' : (isTa ? 'விஞ்ஞான அடிப்படை' : 'Agronomic Baseline');
    String totalReqTitle = isSi ? 'මුළු රසායනික පොහොර අවශ්‍යතාව' : (isTa ? 'மொத்த இரசாயன உரத் தேவை' : 'Total Fertilizer Requirement');
    String stagesTitle = isSi ? 'පොහොර යෙදීමේ කාලසටහන' : (isTa ? 'உரமிடும் கால அட்டவணை' : 'Application Stages & Schedule');
    String organicTitle = isSi ? 'කාබනික පොහොර නිර්දේශය' : (isTa ? 'இயற்கை உரப் பரிந்துரை' : 'Organic Compost & Manure');
    String tipsTitle = isSi ? 'විශේෂ කෘෂි උපදෙස්' : (isTa ? 'நடைமுறை விவசாயக் குறிப்புகள்' : 'Practical Application Tips');
    String askAiBtn = isSi ? 'මෙම බෝගය ගැන AgriAI ගෙන් වැඩිදුර අසන්න' : (isTa ? 'இந்த பயிர் குறித்து AgriAI உடன் பேசவும்' : 'Ask AgriAI About This Crop');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Badge & Total Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                sectionTitle,
                style: TextStyle(
                  color: textColor,
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
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: plan.isAiGenerated ? theme.colorScheme.primary : Colors.amber,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    plan.isAiGenerated ? Icons.auto_awesome : Icons.science_outlined,
                    size: 13,
                    color: plan.isAiGenerated ? theme.colorScheme.primary : Colors.amber.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    plan.isAiGenerated ? 'AI Custom' : baselineTag,
                    style: TextStyle(
                      color: plan.isAiGenerated ? theme.colorScheme.primary : (isDark ? Colors.amberAccent : Colors.amber.shade900),
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
              colors: isDark
                  ? [
                      Colors.green.shade900.withValues(alpha: 0.6),
                      Colors.teal.shade900.withValues(alpha: 0.4),
                    ]
                  : [
                      const Color(0xFFECFDF5),
                      const Color(0xFFD1FAE5),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.greenAccent.withValues(alpha: 0.3) : const Color(0xFFA7F3D0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.cropName} (${plan.acres} ${isSi ? "අක්කර" : (isTa ? "ஏக்கர்" : "Acres")})',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF065F46),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalReqTitle,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF047857),
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
                style: TextStyle(
                  color: isDark ? Colors.greenAccent : const Color(0xFF065F46),
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Fertilizer Cards
        ...plan.fertilizers.map((f) => _buildFertilizerItemCard(f, lang, textColor, subtextColor, isDark, theme)),

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
                    Icon(Icons.schedule_outlined, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stagesTitle,
                        style: TextStyle(
                          color: textColor,
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
                  return _buildStageStep(idx + 1, stage, entry.key == plan.applicationStages.length - 1, textColor, subtextColor, theme);
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
                    Icon(Icons.eco, color: theme.colorScheme.secondary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        organicTitle,
                        style: TextStyle(
                          color: textColor,
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
                    color: textColor.withValues(alpha: 0.9),
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
                    const Icon(Icons.tips_and_updates_outlined, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tipsTitle,
                        style: TextStyle(
                          color: textColor,
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
                    color: subtextColor,
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
            String prompt;
            if (isSi) {
              prompt = 'මම ${plan.cropName} සඳහා අක්කර ${plan.acres} කට පොහොර යෙදීමට බලාපොරොත්තු වෙමි. මෙම බෝගයේ වැඩි ඵලදාවක් ලබා ගැනීමට සහ පොහොර හානි වැළැක්වීමට අමතර උපදෙස් කරුණු වශයෙන් ලබා දෙන්න.';
            } else if (isTa) {
              prompt = 'நான் ${plan.cropName} பயிருக்கு ${plan.acres} ஏக்கரில் உரமிட திட்டமிட்டுள்ளேன். அதிக மகசூல் பெறவும், ஊட்டச்சத்து இழப்பைத் தவிர்க்கவும் கூடுதல் ஆலோசனைகளை குறிப்புகளாக வழங்கவும்.';
            } else {
              prompt = 'I am cultivating ${plan.cropName} on ${plan.acres} acres. Could you provide detailed advice on optimal fertilizer schedule, soil preparation, and nutrient deficiency prevention?';
            }
            context.push('/chat', extra: prompt);
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary),
          label: Text(
            askAiBtn,
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFertilizerItemCard(FertilizerItem item, String lang, Color textColor, Color subtextColor, bool isDark, ThemeData theme) {
    Color iconColor = theme.colorScheme.primary;
    if (item.nutrientType.contains('P')) {
      iconColor = isDark ? Colors.lightBlueAccent : Colors.blue.shade700;
    } else if (item.nutrientType.contains('K')) {
      iconColor = isDark ? Colors.orangeAccent : Colors.orange.shade800;
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
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.nutrientType.isNotEmpty)
                            Text(
                              item.nutrientType,
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withValues(alpha: 0.35)),
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
            Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
            const SizedBox(height: 8),
            if (item.timing.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13, color: subtextColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.timing,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            if (item.purpose.isNotEmpty) ...[
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: theme.colorScheme.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.purpose,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12.5,
                        height: 1.35,
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

  Widget _buildStageStep(int stepNum, FertilizerStage stage, bool isLast, Color textColor, Color subtextColor, ThemeData theme) {
    final hasStageName = stage.stageName.trim().isNotEmpty;
    final hasTiming = stage.timing.trim().isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$stepNum',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasStageName && hasTiming) ...[
                    // Both stage name and timing
                    Text(
                      stage.stageName.trim(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 12, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              stage.timing.trim(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (hasStageName) ...[
                    Text(
                      stage.stageName.trim(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                    ),
                  ] else if (hasTiming) ...[
                    Text(
                      stage.timing.trim(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (stage.instructions.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      stage.instructions.trim(),
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 13.5,
                        height: 1.48,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
