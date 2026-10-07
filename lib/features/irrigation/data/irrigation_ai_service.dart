import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final irrigationAiServiceProvider = Provider((ref) => IrrigationAiService());

class IrrigationPlanResult {
  final double dailyWaterLiters;
  final String recommendedMethod;
  final String frequency;
  final String scheduleAndTips;
  final String criticalGrowthStages;
  final String droughtAndSoilTips;
  final bool isAiGenerated;

  const IrrigationPlanResult({
    required this.dailyWaterLiters,
    required this.recommendedMethod,
    required this.frequency,
    required this.scheduleAndTips,
    required this.criticalGrowthStages,
    required this.droughtAndSoilTips,
    this.isAiGenerated = false,
  });
}

class IrrigationAiService {
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Scientific baseline multiplier for liters per acre per day
  // Average reference evapotranspiration ETo = 4.5 - 5.5 mm/day in tropical zones
  static final Map<String, double> _cropWaterBaseline = {
    'paddy': 22000.0,
    'rice': 22000.0,
    'වී': 22000.0,
    'corn': 6500.0,
    'maize': 6500.0,
    'බඩඉරිඟු': 6500.0,
    'tomato': 4500.0,
    'තක්කාලි': 4500.0,
    'chilli': 4000.0,
    'chili': 4000.0,
    'pepper': 4200.0,
    'මිරිස්': 4000.0,
    'onion': 3800.0,
    'ලූනු': 3800.0,
    'potato': 5000.0,
    'අර්තාපල්': 5000.0,
    'අල': 5000.0,
    'carrot': 3600.0,
    'කැරට්': 3600.0,
    'cabbage': 4200.0,
    'ගෝවා': 4200.0,
    'brinjal': 4600.0,
    'eggplant': 4600.0,
    'වම්බටු': 4600.0,
    'okra': 3800.0,
    'ladies finger': 3800.0,
    'බණ්ඩක්කා': 3800.0,
    'banana': 9000.0,
    'කෙසෙල්': 9000.0,
    'papaya': 5500.0,
    'පැපොල්': 5500.0,
    'watermelon': 4800.0,
    'කොමඩු': 4800.0,
    'cucumber': 4200.0,
    'පිපිඤ්ඤා': 4200.0,
    'pumpkin': 4500.0,
    'වට්ටක්කා': 4500.0,
    'coconut': 7500.0,
    'පොල්': 7500.0,
    'tea': 5200.0,
    'තේ': 5200.0,
    'cinnamon': 4000.0,
    'කුරුඳු': 4000.0,
    'beetroot': 3500.0,
    'බීට්රූට්': 3500.0,
    'beans': 3400.0,
    'බෝංචි': 3400.0,
  };

  IrrigationPlanResult calculateOfflineBaseline({
    required String cropName,
    required double acres,
    required String soilType,
    required String climateZone,
  }) {
    final lowerName = cropName.toLowerCase();
    double baseRate = 4800.0; // Default liters per acre per day

    for (final entry in _cropWaterBaseline.entries) {
      if (lowerName.contains(entry.key)) {
        baseRate = entry.value;
        break;
      }
    }

    // Adjust for soil type
    double soilFactor = 1.0;
    if (soilType.contains('Sandy') || soilType.contains('වැලි')) {
      soilFactor = 1.2; // Sandy soils drain faster
    } else if (soilType.contains('Clay') || soilType.contains('මැටි')) {
      soilFactor = 0.85; // Clay retains water
    }

    // Adjust for climate
    double climateFactor = 1.0;
    if (climateZone.contains('Dry') || climateZone.contains('වියළි')) {
      climateFactor = 1.25;
    } else if (climateZone.contains('Wet') || climateZone.contains('තෙත්')) {
      climateFactor = 0.8;
    }

    final totalDaily = baseRate * acres * soilFactor * climateFactor;

    String method = 'Drip Irrigation (බිංදු ජල සම්පාදනය)';
    String frequency = 'Every 1 - 2 days (දින 1-2කට වරක්)';
    String schedule = 'Water early in the morning (6:00 AM - 8:30 AM) or late afternoon.';
    String critical = 'Vegetative expansion and flowering to fruit/pod setting stages.';
    String droughtTips = 'Apply 5-8cm straw or dried leaves mulch to conserve up to 35% soil moisture.';

    if (lowerName.contains('paddy') || lowerName.contains('rice') || lowerName.contains('වී')) {
      method = 'Controlled Alternate Wetting & Drying (AWD / ක්‍රමානුකූල පාලිත ජල සම්පාදනය)';
      frequency = 'Keep 2-5cm standing water in panicle stage, then dry for 3 days.';
      schedule = 'Do not stress with water deficit during flowering & milk stage.';
      critical = 'Panicle initiation, heading, and flowering.';
      droughtTips = 'Use AWD tube (පැණි බට ක්‍රමය) to save 30% water without yield reduction.';
    } else if (lowerName.contains('banana') || lowerName.contains('කෙසෙල්') || lowerName.contains('papaya') || lowerName.contains('පැපොල්')) {
      method = 'Basin or Micro-sprinkler / Drip around the canopy drip-line';
      frequency = 'Every 2-3 days depending on weather';
      schedule = 'Water around 50cm away from the trunk to avoid root collar rot.';
      critical = 'Shooting/flowering and fruit bunch filling stages.';
      droughtTips = 'Keep dry banana trash or mulch in a 1-meter radius around the stem.';
    } else if (lowerName.contains('corn') || lowerName.contains('බඩඉරිඟු')) {
      method = 'Furrow irrigation (නියරවල් දිගේ) or Rain-gun sprinkler';
      frequency = 'Every 4-5 days';
      schedule = 'Avoid water stagnation around root zones for more than 12 hours.';
      critical = 'Tasseling, silking, and grain filling.';
      droughtTips = 'Intercrop with cowpea or green gram to preserve soil moisture.';
    }

    return IrrigationPlanResult(
      dailyWaterLiters: totalDaily,
      recommendedMethod: method,
      frequency: frequency,
      scheduleAndTips: schedule,
      criticalGrowthStages: critical,
      droughtAndSoilTips: droughtTips,
      isAiGenerated: false,
    );
  }

  Future<IrrigationPlanResult> getAiIrrigationPlan({
    required String cropName,
    required double acres,
    required String soilType,
    required String climateZone,
    required String language,
  }) async {
    // If no API key, return the scientific offline baseline
    if (_apiKey.isEmpty) {
      return calculateOfflineBaseline(
        cropName: cropName,
        acres: acres,
        soilType: soilType,
        climateZone: climateZone,
      );
    }

    String langInstruction = 'Respond in English.';
    if (language == 'si') {
      langInstruction = 'Provide description and tips in natural Sinhala script (සිංහල).';
    } else if (language == 'ta') {
      langInstruction = 'Provide description and tips in Tamil script (தமிழ்).';
    }

    final prompt = '''
You are a senior agricultural irrigation engineer specializing in tropical and Sri Lankan crop water management.
Calculate and formulate an exact, scientifically accurate irrigation plan for:
- Crop: $cropName
- Land Area: $acres Acres
- Soil Type: $soilType
- Climate / Agro-ecological Zone: $climateZone
- Language: $langInstruction

Calculate realistic daily water requirement in Liters for the entire area based on crop evapotranspiration (ETc = ETo x Kc).
Return ONLY a valid JSON object without markdown code blocks, matching this exact schema:
{
  "dailyWaterLiters": number (e.g. 4500.0),
  "recommendedMethod": string (ideal method e.g. Drip, Furrow, Sprinkler with reasoning),
  "frequency": string (exact interval and time e.g. Daily at 6:30 AM),
  "scheduleAndTips": string (actionable watering schedule by stages),
  "criticalGrowthStages": string (growth stages most vulnerable to water stress),
  "droughtAndSoilTips": string (mulching, water saving and soil moisture conservation techniques)
}
''';

    try {
      final model = GenerativeModel(
        model: 'gemini-3.1-flash-lite',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );
      final response = await model.generateContent([Content.text(prompt)]);
      if (response.text != null && response.text!.isNotEmpty) {
        String clean = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(clean);
        return IrrigationPlanResult(
          dailyWaterLiters: (json['dailyWaterLiters'] as num).toDouble(),
          recommendedMethod: json['recommendedMethod'] ?? 'Drip Irrigation',
          frequency: json['frequency'] ?? 'Daily',
          scheduleAndTips: json['scheduleAndTips'] ?? '',
          criticalGrowthStages: json['criticalGrowthStages'] ?? '',
          droughtAndSoilTips: json['droughtAndSoilTips'] ?? '',
          isAiGenerated: true,
        );
      }
    } catch (e) {
      // Fallback model
      try {
        final fallbackModel = GenerativeModel(
          model: 'gemini-3-flash-preview',
          apiKey: _apiKey,
          generationConfig: GenerationConfig(responseMimeType: 'application/json'),
        );
        final fallbackResponse = await fallbackModel.generateContent([Content.text(prompt)]);
        if (fallbackResponse.text != null && fallbackResponse.text!.isNotEmpty) {
          String clean = fallbackResponse.text!.replaceAll('```json', '').replaceAll('```', '').trim();
          final json = jsonDecode(clean);
          return IrrigationPlanResult(
            dailyWaterLiters: (json['dailyWaterLiters'] as num).toDouble(),
            recommendedMethod: json['recommendedMethod'] ?? 'Drip Irrigation',
            frequency: json['frequency'] ?? 'Daily',
            scheduleAndTips: json['scheduleAndTips'] ?? '',
            criticalGrowthStages: json['criticalGrowthStages'] ?? '',
            droughtAndSoilTips: json['droughtAndSoilTips'] ?? '',
            isAiGenerated: true,
          );
        }
      } catch (fallbackError) {
        // Fall back gracefully to offline baseline
      }
    }

    return calculateOfflineBaseline(
      cropName: cropName,
      acres: acres,
      soilType: soilType,
      climateZone: climateZone,
    );
  }
}
