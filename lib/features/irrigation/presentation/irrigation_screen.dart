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
  String _selectedCrop = 'Paddy';
  final _customCropController = TextEditingController();
  final _areaController = TextEditingController(text: '1.0');
  String _areaUnit = 'Acres';
  String _selectedSoil = 'Loamy';
  String _selectedClimate = 'Dry Zone';

  bool _isCustomCrop = false;
  bool _isLoadingAi = false;
  IrrigationPlanResult? _results;

  static const List<Map<String, String>> _cropsData = [
    {'key': 'Paddy', 'en': 'Paddy', 'si': 'වී', 'ta': 'நெல்'},
    {'key': 'Corn', 'en': 'Corn', 'si': 'බඩඉරිඟු', 'ta': 'மக்காச்சோளம்'},
    {'key': 'Tomato', 'en': 'Tomato', 'si': 'තක්කාලි', 'ta': 'தக்காளி'},
    {'key': 'Chilli', 'en': 'Chilli', 'si': 'මිරිස්', 'ta': 'மிளகாய்'},
    {'key': 'Big Onion', 'en': 'Big Onion', 'si': 'ලොකු ලූනු', 'ta': 'பெரிய வெங்காயம்'},
    {'key': 'Potato', 'en': 'Potato', 'si': 'අර්තාපල්', 'ta': 'உருளைக்கிழங்கு'},
    {'key': 'Carrot', 'en': 'Carrot', 'si': 'කැරට්', 'ta': 'கேரட்'},
    {'key': 'Cabbage', 'en': 'Cabbage', 'si': 'ගෝවා', 'ta': 'முட்டைக்கோஸ்'},
    {'key': 'Brinjal', 'en': 'Brinjal / Eggplant', 'si': 'වම්බටු', 'ta': 'கத்தரிக்காய்'},
    {'key': 'Okra', 'en': 'Okra / Ladies Finger', 'si': 'බණ්ඩක්කා', 'ta': 'வெண்டைக்காய்'},
    {'key': 'Banana', 'en': 'Banana', 'si': 'කෙසෙල්', 'ta': 'வாழை'},
    {'key': 'Papaya', 'en': 'Papaya', 'si': 'පැපොල්', 'ta': 'பப்பாளி'},
    {'key': 'Watermelon', 'en': 'Watermelon', 'si': 'පැණි කොමඩු', 'ta': 'தர்பூசணி'},
    {'key': 'Cucumber', 'en': 'Cucumber', 'si': 'පිපිඤ්ඤා', 'ta': 'வெள்ளரி'},
    {'key': 'Pumpkin', 'en': 'Pumpkin', 'si': 'වට්ටක්කා', 'ta': 'பூசணி'},
    {'key': 'Coconut', 'en': 'Coconut', 'si': 'පොල්', 'ta': 'தென்னை'},
    {'key': 'Tea', 'en': 'Tea', 'si': 'තේ', 'ta': 'தேயிலை'},
    {'key': 'Pepper', 'en': 'Pepper', 'si': 'ගම්මිරිස්', 'ta': 'மிளகு'},
  ];

  static const List<Map<String, String>> _soilData = [
    {'key': 'Loamy', 'en': 'Loamy Soil (Fertile & Well Drained)', 'si': 'සාරවත් මැටි මිශ්‍ර පස', 'ta': 'வண்டல் மண்'},
    {'key': 'Sandy', 'en': 'Sandy Soil (Quick Draining)', 'si': 'වැලි සහිත පස', 'ta': 'மணல் மண்'},
    {'key': 'Clay', 'en': 'Clay Soil (High Moisture Retention)', 'si': 'මැටි අධික පස', 'ta': 'களிமண்'},
  ];

  static const List<Map<String, String>> _climateData = [
    {'key': 'Dry Zone', 'en': 'Dry Zone (Yala Season)', 'si': 'වියළි කලාපය (යල කන්නය)', 'ta': 'வறண்ட வலயம் (யால பருவம்)'},
    {'key': 'Wet Zone', 'en': 'Wet Zone (Maha Season)', 'si': 'තෙත් කලාපය (මහ කන්නය)', 'ta': 'ஈரப்பத வலயம் (மஹா பருவம்)'},
    {'key': 'Intermediate Zone', 'en': 'Intermediate Zone', 'si': 'අතරමැදි කලාපය', 'ta': 'இடைப்பட்ட வலயம்'},
  ];

  final List<String> _areaUnits = ['Acres', 'Hectares', 'Perches'];

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
        language: currentLang,
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
          '• ඉඩම් ප්‍රමාණය: $rawArea $_areaUnit\n'
          '• දෛනික ජල අවශ්‍යතාව: ${_results!.dailyWaterLiters.toStringAsFixed(0)} ලීටර\n'
          '• නිර්දේශිත ක්‍රමය: ${_results!.recommendedMethod}\n'
          '• ජලය යෙදීමේ වාර ගණන: ${_results!.frequency}\n'
          '• පස: $_selectedSoil\n'
          '• කලාපය: $_selectedClimate\n\n'
          'කරුණාකර මෙම බෝගයේ ජල සම්පාදනය, නියං සමයේ පස තෙතමනය රඳවා ගැනීමේ ක්‍රම සහ බිංදු ජල පද්ධතියක් සැලසුම් කරන ආකාරය පිළිබඳව උපදෙස් කරුණු වශයෙන් පැහැදිලි කරන්න.';
    } else if (currentLang == 'ta') {
      prompt = 'எனது $crop பயிருக்கான நீர்ப்பாசன திட்டம் கீழே தரப்பட்டுள்ளது:\n\n'
          '• பயிர்: $crop\n'
          '• நிலப் பரப்பு: $rawArea $_areaUnit\n'
          '• தினசரி நீர் தேவை: ${_results!.dailyWaterLiters.toStringAsFixed(0)} லிட்டர்\n'
          '• பரிந்துரைக்கப்பட்ட முறை: ${_results!.recommendedMethod}\n'
          '• பாசன இடைவெளி: ${_results!.frequency}\n'
          '• மண் வகை: $_selectedSoil\n'
          '• வலயம்: $_selectedClimate\n\n'
          'தயவுசெய்து இந்த பயிருக்கான சொட்டு நீர் பாசனம், வறட்சி மேலாண்மை மற்றும் மண் ஈரப்பதப் பாதுகாப்பு ஆலோசனைகளை குறிப்புகளாக தெளிவாக விளக்கவும்.';
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

    final currentLang = ref.watch(localeProvider).languageCode;
    final isSi = currentLang == 'si';
    final isTa = currentLang == 'ta';

    String appTitle = 'Smart Irrigation AI';
    String formHeader = 'Select or Enter Crop';
    String presetBtn = 'Preset List';
    String customBtn = 'Custom Crop';
    String customHint = 'Type any crop (e.g. Dragon Fruit, Cassava)...';
    String landAreaLabel = 'Land Area';
    String unitLabel = 'Unit';
    String soilLabel = 'Soil Type';
    String climateLabel = 'Climate Zone';
    String calculateBtn = _isLoadingAi ? 'Consulting Smart AI Engine...' : 'Calculate & Search with AI';
    String planTitleSuffix = 'Irrigation Plan';
    String dailyDemandTitle = 'Total Daily Water Demand';
    String dailyDemandSub = 'Estimated requirement for healthy crop canopy';
    String litersPerDay = 'Liters / Day';
    String recMethodTitle = 'Recommended Method';
    String freqTitle = 'Watering Frequency & Interval';
    String stageTitle = 'Growth Stage Schedule';
    String droughtTitle = 'Water Conservation & Drought Tips';
    String chatAiBtn = 'Chat with AgriAI about this Irrigation Plan';

    if (isSi) {
      appTitle = 'ස්මාර්ට් වාරිමාර්ග AI';
      formHeader = 'බෝගය තෝරන්න හෝ ඇතුළත් කරන්න';
      presetBtn = 'ලැයිස්තුව';
      customBtn = 'වෙනත් බෝගයක්';
      customHint = 'ඕනෑම බෝගයක නම ලියන්න (උදා: ඩ්‍රැගන් ෆෘට්, මඤ්ඤොක්කා)...';
      landAreaLabel = 'ඉඩම් ප්‍රමාණය';
      unitLabel = 'ඒකකය';
      soilLabel = 'පස් වර්ගය';
      climateLabel = 'කාලගුණ කලාපය';
      calculateBtn = _isLoadingAi ? 'AI ගණනය කරමින් පවතී...' : 'AI මගින් ජල අවශ්‍යතාව ගණනය කරන්න';
      planTitleSuffix = 'වාරිමාර්ග සැලැස්ම';
      dailyDemandTitle = 'දෛනික සමස්ත ජල අවශ්‍යතාවය';
      dailyDemandSub = 'නිරෝගී බෝග වර්ධනය සඳහා නිර්දේශිත ජල ප්‍රමාණය';
      litersPerDay = 'ලීටර / දිනකට';
      recMethodTitle = 'නිර්දේශිත ක්‍රමය';
      freqTitle = 'වාර ගණන සහ කාල පරතරය';
      stageTitle = 'අවධි අනුව කාලසටහන';
      droughtTitle = 'ජල සංරක්ෂණය සහ නියඟයට උපදෙස්';
      chatAiBtn = 'මෙම වාරිමාර්ග සැලැස්ම ගැන AgriAI සමඟ කතා කරන්න';
    } else if (isTa) {
      appTitle = 'ஸ்மார்ட் நீர்ப்பாசன AI';
      formHeader = 'பயிரைத் தேர்ந்தெடுக்கவும் அல்லது உள்ளிடவும்';
      presetBtn = 'பட்டியல்';
      customBtn = 'மற்ற பயிர்';
      customHint = 'எந்தவொரு பயிர் பெயரையும் தட்டச்சு செய்யவும்...';
      landAreaLabel = 'நிலப் பரப்பு';
      unitLabel = 'அலகு';
      soilLabel = 'மண் வகை';
      climateLabel = 'காலநிலை வலயம்';
      calculateBtn = _isLoadingAi ? 'AI கணக்கிடுகிறது...' : 'AI மூலம் நீர்ப்பாசனத்தைக் கணக்கிடுக';
      planTitleSuffix = 'நீர்ப்பாசன திட்டம்';
      dailyDemandTitle = 'மொத்த தினசரி நீர் தேவை';
      dailyDemandSub = 'ஆரோக்கியமான பயிர் வளர்ச்சிக்கான பரிந்துரைக்கப்பட்ட அளவு';
      litersPerDay = 'லிட்டர் / நாள்';
      recMethodTitle = 'பரிந்துரைக்கப்பட்ட முறை';
      freqTitle = 'பாசன இடைவெளி';
      stageTitle = 'பயிர் வளர்ச்சி நிலை அட்டவணை';
      droughtTitle = 'நீர் சேமிப்பு மற்றும் வறட்சி குறிப்புகள்';
      chatAiBtn = 'இந்த நீர்ப்பாசன திட்டம் குறித்து AgriAI உடன் பேசவும்';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          appTitle,
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
                              formHeader,
                              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => setState(() => _isCustomCrop = !_isCustomCrop),
                              child: Text(
                                _isCustomCrop ? presetBtn : customBtn,
                                style: const TextStyle(color: Colors.blueAccent),
                              ),
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
                            items: _cropsData.map((c) {
                              final label = isSi ? c['si']! : (isTa ? c['ta']! : c['en']!);
                              return DropdownMenuItem(
                                value: c['key'],
                                child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
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
                              hintText: customHint,
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
                                    landAreaLabel,
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
                                    unitLabel,
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
                                    items: _areaUnits.map((u) {
                                      String unitName = u;
                                      if (isSi) {
                                        if (u == 'Acres') unitName = 'අක්කර';
                                        if (u == 'Hectares') unitName = 'හෙක්ටයාර';
                                        if (u == 'Perches') unitName = 'පර්චස්';
                                      } else if (isTa) {
                                        if (u == 'Acres') unitName = 'ஏக்கர்';
                                        if (u == 'Hectares') unitName = 'ஹெக்டேர்';
                                        if (u == 'Perches') unitName = 'பேர்ச்';
                                      }
                                      return DropdownMenuItem(value: u, child: Text(unitName, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)));
                                    }).toList(),
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
                          soilLabel,
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
                          items: _soilData.map((s) {
                            final label = isSi ? s['si']! : (isTa ? s['ta']! : s['en']!);
                            return DropdownMenuItem(value: s['key'], child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedSoil = val!),
                        ),

                        const SizedBox(height: 18),

                        // Climate Zone
                        Text(
                          climateLabel,
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
                          items: _climateData.map((c) {
                            final label = isSi ? c['si']! : (isTa ? c['ta']! : c['en']!);
                            return DropdownMenuItem(value: c['key'], child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)));
                          }).toList(),
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
                            calculateBtn,
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

                    // Plan Title & Source Tag
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '${_getActiveCropName()} $planTitleSuffix',
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
                                _results!.isAiGenerated ? 'AI Custom' : (isSi ? 'විද්‍යාත්මක' : (isTa ? 'விஞ்ஞான அடிப்படை' : 'Scientific')),
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
                                      dailyDemandTitle,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dailyDemandSub,
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
                                litersPerDay,
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
                      recMethodTitle,
                      _results!.recommendedMethod,
                      Icons.tune_rounded,
                      Colors.teal,
                    ),
                    const SizedBox(height: 12),
                    _buildResultCard(
                      context,
                      freqTitle,
                      _results!.frequency,
                      Icons.update_rounded,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildResultCard(
                      context,
                      stageTitle,
                      _results!.criticalGrowthStages,
                      Icons.eco_rounded,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildResultCard(
                      context,
                      droughtTitle,
                      _results!.droughtAndSoilTips,
                      Icons.shield_outlined,
                      Colors.amber.shade700,
                    ),

                    const SizedBox(height: 20),

                    // Chat with AI Action
                    FilledButton.icon(
                      onPressed: _chatWithAgriAi,
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                      label: Text(
                        chatAiBtn,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
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
