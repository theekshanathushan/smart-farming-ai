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
    String language = 'en',
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
    if (soilType.toLowerCase().contains('sandy') || soilType.contains('වැලි') || soilType.contains('மணல்')) {
      soilFactor = 1.2; // Sandy soils drain faster
    } else if (soilType.toLowerCase().contains('clay') || soilType.contains('මැටි') || soilType.contains('களிமண்')) {
      soilFactor = 0.85; // Clay retains water
    }

    // Adjust for climate
    double climateFactor = 1.0;
    if (climateZone.toLowerCase().contains('dry') || climateZone.contains('වියළි') || climateZone.contains('வறண்ட')) {
      climateFactor = 1.25;
    } else if (climateZone.toLowerCase().contains('wet') || climateZone.contains('තෙත්') || climateZone.contains('ஈரப்பத')) {
      climateFactor = 0.8;
    }

    final totalDaily = baseRate * acres * soilFactor * climateFactor;

    final isSi = language == 'si';
    final isTa = language == 'ta';

    String method;
    String frequency;
    String schedule;
    String critical;
    String droughtTips;

    if (lowerName.contains('paddy') || lowerName.contains('rice') || lowerName.contains('වී') || lowerName.contains('நெல்')) {
      if (isSi) {
        method = 'ක්‍රමානුකූල පාලිත ජල සම්පාදනය (AWD)';
        frequency = 'කරල් හටගන්නා අවධියේ 2-5cm ජලය රඳවා තබා, ඉන්පසු දින 3ක් ජලය බැස යාමට හරින්න.';
        schedule = 'මල් පිපෙන හා කරල් පැසෙන අවධියේ ජල හිඟයක් ඇතිවීම වළක්වන්න.';
        critical = 'කරල් හටගැනීම, මල් පිපීම සහ කරල් පැසෙන අවධිය.';
        droughtTips = 'අස්වැන්න අඩු නොකර 30%ක් ජලය ඉතිරි කර ගැනීමට පැණි බට ක්‍රමය භාවිතා කරන්න.';
      } else if (isTa) {
        method = 'கட்டுப்படுத்தப்பட்ட மாற்று நனைத்தல் மற்றும் உலர்த்தல் (AWD)';
        frequency = 'கதிர் விடும் பருவத்தில் 2-5 செ.மீ நீர் தேக்கி, பின் 3 நாட்கள் உலர விடவும்.';
        schedule = 'பூக்கும் மற்றும் பால் பிடிக்கும் பருவத்தில் நீர் பற்றாக்குறை ஏற்படாமல் பார்த்துக் கொள்ளவும்.';
        critical = 'கதிர் உருவாக்கம் மற்றும் பூக்கும் பருவம்.';
        droughtTips = 'மகசூல் குறையாமல் 30% நீரைச் சேமிக்க துளையிடப்பட்ட குழாய் முறையைப் பயன்படுத்தவும்.';
      } else {
        method = 'Controlled Alternate Wetting & Drying (AWD)';
        frequency = 'Keep 2-5cm standing water in panicle stage, then dry for 3 days.';
        schedule = 'Do not stress with water deficit during flowering and milk stage.';
        critical = 'Panicle initiation, heading, and flowering.';
        droughtTips = 'Use AWD tube field monitoring to save 30% water without yield reduction.';
      }
    } else if (lowerName.contains('banana') || lowerName.contains('කෙසෙල්') || lowerName.contains('வாழை') ||
               lowerName.contains('papaya') || lowerName.contains('පැපොල්') || lowerName.contains('பப்பாளி')) {
      if (isSi) {
        method = 'බිංදු ජල සම්පාදනය හෝ පාමුල වාරිමාර්ගය';
        frequency = 'කාලගුණය අනුව දින 2-3 කට වරක්';
        schedule = 'කඳ කුණුවීම වැළැක්වීම සඳහා කඳේ සිට සෙන්ටිමීටර 50 ක් පමණ ඈතින් ජලය යොදන්න.';
        critical = 'මල් හටගැනීම සහ කැන/ගෙඩි වර්ධනය වන අවධිය.';
        droughtTips = 'කඳ වටා මීටර 1 ක අරයක් තුළ වියළි කොළ හෝ පිදුරු වසුන් යොදන්න.';
      } else if (isTa) {
        method = 'சொட்டு நீர் பாசனம் அல்லது வட்டப்பாத்தி பாசனம்';
        frequency = 'வானிலையைப் பொறுத்து 2-3 நாட்களுக்கு ஒருமுறை';
        schedule = 'தண்டு அழுகலைத் தடுக்க தண்டிலிருந்து 50 செ.மீ தள்ளி நீர் பாய்ச்சவும்.';
        critical = 'பூக்கும் மற்றும் காய் பிடிக்கும் பருவம்.';
        droughtTips = 'தண்டின் அடிப்பகுதியில் 1 மீட்டர் சுற்றளவில் உலர் இலை மூடாக்கு இடவும்.';
      } else {
        method = 'Basin or Micro-sprinkler / Drip around canopy drip-line';
        frequency = 'Every 2-3 days depending on weather';
        schedule = 'Water around 50cm away from the trunk to avoid root collar rot.';
        critical = 'Shooting/flowering and fruit bunch filling stages.';
        droughtTips = 'Keep dry banana trash or mulch in a 1-meter radius around the stem.';
      }
    } else if (lowerName.contains('corn') || lowerName.contains('බඩඉරිඟු') || lowerName.contains('மக்காச்சோளம்')) {
      if (isSi) {
        method = 'නියරවල් දිගේ ජලය සැපයීම හෝ විසුරුම් ජල සම්පාදනය';
        frequency = 'දින 4-5 කට වරක්';
        schedule = 'මුල් කලාපය අවට පැය 12 කට වඩා ජලය එකතැන පල්වීම වළක්වන්න.';
        critical = 'මල් පිපීම සහ කරල් පිරීමේ අවධිය.';
        droughtTips = 'පසෙහි තෙතමනය රැක ගැනීමට කවුපි හෝ මුංඇට සමඟ මිශ්‍ර බෝග වගා කරන්න.';
      } else if (isTa) {
        method = 'சால் பாசனம் அல்லது தெளிப்பு நீர் பாசனம்';
        frequency = '4-5 நாட்களுக்கு ஒருமுறை';
        schedule = 'வேர் பகுதியில் 12 மணி நேரத்திற்கும் மேலாக நீர் தேங்குவதைத் தவிர்க்கவும்.';
        critical = 'பூக்கும் மற்றும் கதிர் பால் பிடிக்கும் பருவம்.';
        droughtTips = 'மண் ஈரப்பதத்தைப் பாதுகாக்க தட்டைப்பயறு அல்லது பாசிப்பயறு ஊடுபயிராக இடவும்.';
      } else {
        method = 'Furrow irrigation or Rain-gun sprinkler';
        frequency = 'Every 4-5 days';
        schedule = 'Avoid water stagnation around root zones for more than 12 hours.';
        critical = 'Tasseling, silking, and grain filling.';
        droughtTips = 'Intercrop with cowpea or green gram to preserve soil moisture.';
      }
    } else {
      if (isSi) {
        method = 'බිංදු ජල සම්පාදනය';
        frequency = 'දින 1-2 කට වරක්';
        schedule = 'උදෑසන (පෙ.ව. 6:00 - 8:30) හෝ සවස් කාලයේ ජලය යොදන්න.';
        critical = 'ශාක වර්ධන හා මල්/කරල් හටගන්නා අවධිය.';
        droughtTips = 'පසෙහි තෙතමනය 35% ක් දක්වා ආරක්ෂා කර ගැනීමට සෙන්ටිමීටර 5-8 ක වියළි කොළ හෝ පිදුරු වසුන් යොදන්න.';
      } else if (isTa) {
        method = 'சொட்டு நீர் பாசனம்';
        frequency = '1-2 நாட்களுக்கு ஒருமுறை';
        schedule = 'அதிகாலை (காலை 6:00 - 8:30) அல்லது மாலையில் நீர் பாய்ச்சவும்.';
        critical = 'வளர்ச்சி மற்றும் பூக்கும் பருவம்.';
        droughtTips = 'மண் ஈரப்பதத்தை 35% வரை பாதுகாக்க 5-8 செ.மீ வைக்கோல் மூடாக்கு இடவும்.';
      } else {
        method = 'Drip Irrigation';
        frequency = 'Every 1 - 2 days';
        schedule = 'Water early in the morning (6:00 AM - 8:30 AM) or late afternoon.';
        critical = 'Vegetative expansion and flowering to fruit/pod setting stages.';
        droughtTips = 'Apply 5-8cm straw or dried leaves mulch to conserve up to 35% soil moisture.';
      }
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
        language: language,
      );
    }

    String langInstruction = 'Respond 100% EXCLUSIVELY in pure English. Do NOT include any Sinhala or Tamil words or characters.';
    if (language == 'si') {
      langInstruction = 'Provide ALL text fields ("recommendedMethod", "frequency", "scheduleAndTips", "criticalGrowthStages", "droughtAndSoilTips") 100% EXCLUSIVELY in pure Sinhala script (සිංහල). Zero English words. Zero Singlish.';
    } else if (language == 'ta') {
      langInstruction = 'Provide ALL text fields ("recommendedMethod", "frequency", "scheduleAndTips", "criticalGrowthStages", "droughtAndSoilTips") 100% EXCLUSIVELY in pure Tamil script (தமிழ்). Zero English words. Zero Tanglish.';
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
        model: 'gemini-2.0-flash',
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
          model: 'gemini-1.5-flash',
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
      language: language,
    );
  }
}
