import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fertilizerAiServiceProvider = Provider((ref) => FertilizerAiService());

class FertilizerItem {
  final String name;
  final double amountKg;
  final String nutrientType;
  final String timing;
  final String purpose;

  const FertilizerItem({
    required this.name,
    required this.amountKg,
    required this.nutrientType,
    this.timing = '',
    this.purpose = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'amountKg': amountKg,
    'nutrientType': nutrientType,
    'timing': timing,
    'purpose': purpose,
  };
}

class FertilizerStage {
  final String stageName;
  final String timing;
  final String instructions;

  const FertilizerStage({
    required this.stageName,
    required this.timing,
    required this.instructions,
  });
}

class FertilizerPlanResult {
  final String cropName;
  final double acres;
  final List<FertilizerItem> fertilizers;
  final List<FertilizerStage> applicationStages;
  final String organicAlternative;
  final String practicalTips;
  final bool isAiGenerated;

  const FertilizerPlanResult({
    required this.cropName,
    required this.acres,
    required this.fertilizers,
    required this.applicationStages,
    required this.organicAlternative,
    required this.practicalTips,
    this.isAiGenerated = false,
  });

  double get totalChemicalKg =>
      fertilizers.fold(0.0, (sum, item) => sum + item.amountKg);
}

class FertilizerAiService {
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Comprehensive agronomic offline rates per acre (kg)
  static final Map<String, Map<String, double>> _cropNutrientRates = {
    // Cereals
    'paddy': {'Urea': 100.0, 'TSP': 25.0, 'MOP': 30.0},
    'rice': {'Urea': 100.0, 'TSP': 25.0, 'MOP': 30.0},
    'වී': {'Urea': 100.0, 'TSP': 25.0, 'MOP': 30.0},
    'corn': {'Urea': 90.0, 'TSP': 40.0, 'MOP': 35.0},
    'maize': {'Urea': 90.0, 'TSP': 40.0, 'MOP': 35.0},
    'බඩඉරිඟු': {'Urea': 90.0, 'TSP': 40.0, 'MOP': 35.0},

    // Solanaceous & Vegetables
    'tomato': {'Urea': 65.0, 'TSP': 50.0, 'MOP': 45.0},
    'තක්කාලි': {'Urea': 65.0, 'TSP': 50.0, 'MOP': 45.0},
    'chilli': {'Urea': 75.0, 'TSP': 60.0, 'MOP': 50.0},
    'chili': {'Urea': 75.0, 'TSP': 60.0, 'MOP': 50.0},
    'pepper': {'Urea': 75.0, 'TSP': 60.0, 'MOP': 50.0},
    'මිරිස්': {'Urea': 75.0, 'TSP': 60.0, 'MOP': 50.0},
    'brinjal': {'Urea': 70.0, 'TSP': 55.0, 'MOP': 45.0},
    'eggplant': {'Urea': 70.0, 'TSP': 55.0, 'MOP': 45.0},
    'aubergine': {'Urea': 70.0, 'TSP': 55.0, 'MOP': 45.0},
    'වම්බටු': {'Urea': 70.0, 'TSP': 55.0, 'MOP': 45.0},
    'okra': {'Urea': 55.0, 'TSP': 40.0, 'MOP': 35.0},
    'ladies finger': {'Urea': 55.0, 'TSP': 40.0, 'MOP': 35.0},
    'බණ්ඩක්කා': {'Urea': 55.0, 'TSP': 40.0, 'MOP': 35.0},
    'cabbage': {'Urea': 85.0, 'TSP': 75.0, 'MOP': 60.0},
    'ගෝවා': {'Urea': 85.0, 'TSP': 75.0, 'MOP': 60.0},
    'carrot': {'Urea': 55.0, 'TSP': 65.0, 'MOP': 60.0},
    'කැරට්': {'Urea': 55.0, 'TSP': 65.0, 'MOP': 60.0},
    'beetroot': {'Urea': 50.0, 'TSP': 60.0, 'MOP': 65.0},
    'බීට්රූට්': {'Urea': 50.0, 'TSP': 60.0, 'MOP': 65.0},

    // Tubers & Bulbs
    'onion': {'Urea': 80.0, 'TSP': 70.0, 'MOP': 50.0},
    'ලූනු': {'Urea': 80.0, 'TSP': 70.0, 'MOP': 50.0},
    'potato': {'Urea': 110.0, 'TSP': 110.0, 'MOP': 85.0},
    'අර්තාපල්': {'Urea': 110.0, 'TSP': 110.0, 'MOP': 85.0},
    'අල': {'Urea': 110.0, 'TSP': 110.0, 'MOP': 85.0},
    'sweet potato': {'Urea': 40.0, 'TSP': 50.0, 'MOP': 75.0},
    'බතල': {'Urea': 40.0, 'TSP': 50.0, 'MOP': 75.0},
    'manioc': {'Urea': 45.0, 'TSP': 40.0, 'MOP': 65.0},
    'cassava': {'Urea': 45.0, 'TSP': 40.0, 'MOP': 65.0},
    'මඤ්ඤොක්කා': {'Urea': 45.0, 'TSP': 40.0, 'MOP': 65.0},

    // Cucurbits
    'watermelon': {'Urea': 55.0, 'TSP': 45.0, 'MOP': 40.0},
    'කොමඩු': {'Urea': 55.0, 'TSP': 45.0, 'MOP': 40.0},
    'cucumber': {'Urea': 50.0, 'TSP': 40.0, 'MOP': 40.0},
    'පිපිඤ්ඤා': {'Urea': 50.0, 'TSP': 40.0, 'MOP': 40.0},
    'pumpkin': {'Urea': 50.0, 'TSP': 45.0, 'MOP': 35.0},
    'වට්ටක්කා': {'Urea': 50.0, 'TSP': 45.0, 'MOP': 35.0},
    'bitter gourd': {'Urea': 60.0, 'TSP': 45.0, 'MOP': 45.0},
    'කරවිල': {'Urea': 60.0, 'TSP': 45.0, 'MOP': 45.0},
    'snake gourd': {'Urea': 55.0, 'TSP': 40.0, 'MOP': 40.0},
    'පත්ථෝල': {'Urea': 55.0, 'TSP': 40.0, 'MOP': 40.0},

    // Legumes (Require less N due to nodule fixation)
    'beans': {'Urea': 30.0, 'TSP': 50.0, 'MOP': 35.0},
    'බෝංචි': {'Urea': 30.0, 'TSP': 50.0, 'MOP': 35.0},
    'green gram': {'Urea': 20.0, 'TSP': 45.0, 'MOP': 25.0},
    'මුං ඇට': {'Urea': 20.0, 'TSP': 45.0, 'MOP': 25.0},
    'cowpea': {'Urea': 20.0, 'TSP': 45.0, 'MOP': 25.0},
    'කවුපි': {'Urea': 20.0, 'TSP': 45.0, 'MOP': 25.0},

    // Fruits & Perennials
    'banana': {'Urea': 130.0, 'TSP': 65.0, 'MOP': 150.0},
    'කෙසෙල්': {'Urea': 130.0, 'TSP': 65.0, 'MOP': 150.0},
    'papaya': {'Urea': 85.0, 'TSP': 70.0, 'MOP': 90.0},
    'පැපොල්': {'Urea': 85.0, 'TSP': 70.0, 'MOP': 90.0},
    'tea': {'Urea': 90.0, 'TSP': 35.0, 'MOP': 45.0},
    'තේ': {'Urea': 90.0, 'TSP': 35.0, 'MOP': 45.0},
    'coconut': {'Urea': 75.0, 'TSP': 50.0, 'MOP': 65.0},
    'පොල්': {'Urea': 75.0, 'TSP': 50.0, 'MOP': 65.0},
    'cinnamon': {'Urea': 60.0, 'TSP': 35.0, 'MOP': 45.0},
    'කුරුඳු': {'Urea': 60.0, 'TSP': 35.0, 'MOP': 45.0},
  };

  FertilizerPlanResult calculateOfflineBaseline({
    required String cropName,
    required double acres,
    String language = 'en',
  }) {
    final lower = cropName.toLowerCase().trim();
    Map<String, double> rates = {'Urea': 60.0, 'TSP': 45.0, 'MOP': 40.0}; // Safe default

    for (final entry in _cropNutrientRates.entries) {
      if (lower.contains(entry.key)) {
        rates = entry.value;
        break;
      }
    }

    final isSi = language == 'si';
    final isTa = language == 'ta';

    final ureaAmount = (rates['Urea'] ?? 60.0) * acres;
    final tspAmount = (rates['TSP'] ?? 45.0) * acres;
    final mopAmount = (rates['MOP'] ?? 40.0) * acres;

    final List<FertilizerItem> items = [
      FertilizerItem(
        name: isSi ? 'යුරියා (Urea - 46% N)' : (isTa ? 'யூரியா (Urea)' : 'Urea (46% Nitrogen)'),
        amountKg: double.parse(ureaAmount.toStringAsFixed(1)),
        nutrientType: 'Nitrogen (N)',
        timing: isSi ? 'මූලික යෙදුම 25% + ඉතිරිය මතුපිට යෙදුම් 2කට' : (isTa ? '25% ஆரம்ப உரம் + மீதி 2 முறை' : '25% at Basal + 75% in 2 Top Dressings'),
        purpose: isSi ? 'ශාකයේ පත්‍ර හා කඳ සවිමත්ව ඉක්මනින් වර්ධනය කිරීමට' : 'Promotes leafy growth, tillering and stem vigor',
      ),
      FertilizerItem(
        name: isSi ? 'මඩ පොහොර / ත්‍රිත්ව සුපර් පොස්පේට් (TSP - 46% P₂O₅)' : (isTa ? 'டிஎஸ்பி (TSP)' : 'Triple Super Phosphate (TSP - 46% P₂O₅)'),
        amountKg: double.parse(tspAmount.toStringAsFixed(1)),
        nutrientType: 'Phosphorus (P)',
        timing: isSi ? '100% ක්ම බීජ සිටුවීමට/පැල කිරීමට පෙර මූලික පොහොර ලෙස පසට කලවම් කරන්න' : '100% applied as Basal dressing before planting',
        purpose: isSi ? 'ශක්තිමත් මුල් පද්ධතියක් සාදා ගැනීමට සහ මුල් බැසීම වේගවත් කිරීමට' : 'Stimulates deep root development and early seedling vigor',
      ),
      FertilizerItem(
        name: isSi ? 'බන්ඩි පොහොර / මියුරියේට් ඔෆ් පොටෑෂ් (MOP - 60% K₂O)' : (isTa ? 'எம்ஓபி (MOP)' : 'Muriate of Potash (MOP - 60% K₂O)'),
        amountKg: double.parse(mopAmount.toStringAsFixed(1)),
        nutrientType: 'Potassium (K)',
        timing: isSi ? '50% මූලික පොහොර ලෙසත්, 50% මල්/කරල් හටගන්නා අවධියේදීත්' : '50% at Basal + 50% at Flowering/Fruit setting',
        purpose: isSi ? 'පලදාව, කරල්වල ප්‍රමාණය, ගුණාත්මක බව සහ රෝග වලට ඔරොත්තු දීම වැඩි කිරීමට' : 'Enhances fruit size, grain weight, disease resistance and quality',
      ),
    ];

    final stages = [
      FertilizerStage(
        stageName: isSi ? 'මූලික පොහොර යෙදුම (Basal Dressing)' : 'Basal Dressing (At Planting)',
        timing: isSi ? 'බීජ සිටුවීමට හෝ පැල සිටුවීමට දින 1-2 කට පෙර' : 'At or 1-2 days before planting',
        instructions: isSi
            ? 'මුළු TSP ප්‍රමාණයම (${tspAmount.toStringAsFixed(1)} kg) සහ MOP වලින් අඩක් (${(mopAmount * 0.5).toStringAsFixed(1)} kg) පසට දමා හොඳින් මිශ්‍ර කරන්න.'
            : 'Incorporate 100% of TSP (${tspAmount.toStringAsFixed(1)} kg) and 50% of MOP (${(mopAmount * 0.5).toStringAsFixed(1)} kg) into the root zone.',
      ),
      FertilizerStage(
        stageName: isSi ? 'පළමු මතුපිට යෙදුම (1st Top Dressing)' : '1st Top Dressing (Early Vegetative)',
        timing: isSi ? 'සිටුවා සති 2-3 කට පසු' : '2-3 weeks after transplanting / emergence',
        instructions: isSi
            ? 'යුරියා වලින් අඩක් (${(ureaAmount * 0.5).toStringAsFixed(1)} kg) පැල වටා පස තෙතමනය සහිත අවස්ථාවකදී යොදන්න.'
            : 'Apply 50% of Urea (${(ureaAmount * 0.5).toStringAsFixed(1)} kg) around the plant drip line when soil is moist.',
      ),
      FertilizerStage(
        stageName: isSi ? 'දෙවන මතුපිට යෙදුම (2nd Top Dressing)' : '2nd Top Dressing (Flowering & Yield Stage)',
        timing: isSi ? 'සිටුවා සති 5-7 කට පසු (මල්/කරල් ඒමට පෙර)' : '5-7 weeks after planting (Before panicle/flowering)',
        instructions: isSi
            ? 'ඉතිරි යුරියා (${(ureaAmount * 0.5).toStringAsFixed(1)} kg) සහ ඉතිරි MOP (${(mopAmount * 0.5).toStringAsFixed(1)} kg) පසට යොදා සැහැල්ලුවෙන් පස් කරන්න.'
            : 'Apply remaining Urea (${(ureaAmount * 0.5).toStringAsFixed(1)} kg) and remaining MOP (${(mopAmount * 0.5).toStringAsFixed(1)} kg) followed by light irrigation.',
      ),
    ];

    final organicAlt = isSi
        ? 'හොඳින් දිරාපත් වූ කොම්පෝස්ට් හෝ ගොම පොහොර ${(2000 * acres).toStringAsFixed(0)} - ${(3500 * acres).toStringAsFixed(0)} kg පස සකස් කරන විට එක් කරන්න. इससे පසේ සාරවත්බව දෙගුණ වේ.'
        : 'Apply ${(2000 * acres).toStringAsFixed(0)} - ${(3500 * acres).toStringAsFixed(0)} kg of well-decomposed organic compost or farmyard manure during land preparation to build organic carbon.';

    final tips = isSi
        ? '1. තද වැසි ලැබෙන විට පොහොර නොයොදන්න (සෝදා යාම වැළැක්වීමට).\n2. පොහොර යෙදීමට පෙර පසේ ප්‍රමාණවත් තෙතමනයක් තිබිය යුතුය.\n3. යුරියා යෙදූ පසු පස් වලින් සැහැල්ලුවෙන් වසන්න (වාෂ්පීකරණය වැළැක්වීමට).'
        : '1. Never apply fertilizer right before heavy downpours to avoid leaching.\n2. Ensure soil is moist before application.\n3. Lightly incorporate Urea into topsoil to prevent ammonia volatilization.';

    return FertilizerPlanResult(
      cropName: cropName,
      acres: acres,
      fertilizers: items,
      applicationStages: stages,
      organicAlternative: organicAlt,
      practicalTips: tips,
      isAiGenerated: false,
    );
  }

  Future<FertilizerPlanResult> getAiFertilizerPlan({
    required String cropName,
    required double acres,
    required String language,
    String? growthStage,
    String? soilType,
  }) async {
    // If no API key, use rich offline baseline
    if (_apiKey.isEmpty) {
      return calculateOfflineBaseline(
        cropName: cropName,
        acres: acres,
        language: language,
      );
    }

    String langInstruction = 'Respond in English.';
    if (language == 'si') {
      langInstruction = 'Respond in fluent, natural Sinhala script (සිංහල). Keep scientific nutrient names like Urea, TSP, MOP followed by Sinhala translations.';
    } else if (language == 'ta') {
      langInstruction = 'Respond in clear Tamil script (தமிழ்).';
    }

    final prompt = '''
You are a senior agronomist and soil scientist specializing in tropical crop nutrition and Department of Agriculture guidelines.
Calculate the exact scientific fertilizer requirement and step-by-step feeding plan for:
- Crop: $cropName
- Land Area: $acres Acres
${growthStage != null && growthStage.isNotEmpty ? '- Target Growth Stage: $growthStage' : ''}
${soilType != null && soilType.isNotEmpty ? '- Soil Condition: $soilType' : ''}
- Language: $langInstruction

Calculate realistic quantities in Kilograms (kg) for the specified acreage ($acres acres).
Include standard fertilizers (such as Urea for Nitrogen, TSP/Rock Phosphate for Phosphorus, MOP for Potassium, and any crop-specific micronutrients if necessary).

Return ONLY a valid JSON object without markdown code blocks, matching this exact schema:
{
  "fertilizers": [
    {
      "name": "string (e.g. Urea (යුරියා / N))",
      "amountKg": number (exact total kg for $acres acres, e.g. 90.0),
      "nutrientType": "string (e.g. Nitrogen - N)",
      "timing": "string (when to apply, e.g. 25% basal + 2 split top dressings)",
      "purpose": "string (e.g. Leafy growth and tillering)"
    }
  ],
  "applicationStages": [
    {
      "stageName": "string (e.g. Basal Dressing / මූලික යෙදුම)",
      "timing": "string (e.g. At planting / Day 0)",
      "instructions": "string (detailed instructions for farmer)"
    }
  ],
  "organicAlternative": "string (recommended compost or bio-fertilizer amounts in kg or tons for $acres acres)",
  "practicalTips": "string (practical agronomy guidelines on moisture, rain, split application, and soil health)"
}
''';

    try {
      final model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );
      final response = await model.generateContent([Content.text(prompt)]);
      if (response.text != null && response.text!.isNotEmpty) {
        String clean = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(clean);
        return _parsePlan(json, cropName, acres);
      }
    } catch (e) {
      debugPrint('Gemini primary model failed: $e. Trying fallback...');
      try {
        final fallbackModel = GenerativeModel(
          model: 'gemini-flash-lite-latest',
          apiKey: _apiKey,
          generationConfig: GenerationConfig(responseMimeType: 'application/json'),
        );
        final response = await fallbackModel.generateContent([Content.text(prompt)]);
        if (response.text != null && response.text!.isNotEmpty) {
          String clean = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
          final json = jsonDecode(clean);
          return _parsePlan(json, cropName, acres);
        }
      } catch (fallbackError) {
        debugPrint('Gemini fallback failed: $fallbackError');
      }
    }

    // Graceful offline fallback
    return calculateOfflineBaseline(
      cropName: cropName,
      acres: acres,
      language: language,
    );
  }

  FertilizerPlanResult _parsePlan(Map<String, dynamic> json, String cropName, double acres) {
    final rawFertilizers = json['fertilizers'] as List? ?? [];
    final fertilizers = rawFertilizers.map((item) {
      return FertilizerItem(
        name: item['name'] ?? '',
        amountKg: (item['amountKg'] as num?)?.toDouble() ?? 0.0,
        nutrientType: item['nutrientType'] ?? '',
        timing: item['timing'] ?? '',
        purpose: item['purpose'] ?? '',
      );
    }).toList();

    final rawStages = json['applicationStages'] as List? ?? [];
    final stages = rawStages.map((stage) {
      return FertilizerStage(
        stageName: stage['stageName'] ?? '',
        timing: stage['timing'] ?? '',
        instructions: stage['instructions'] ?? '',
      );
    }).toList();

    return FertilizerPlanResult(
      cropName: cropName,
      acres: acres,
      fertilizers: fertilizers,
      applicationStages: stages,
      organicAlternative: json['organicAlternative'] ?? '',
      practicalTips: json['practicalTips'] ?? '',
      isAiGenerated: true,
    );
  }
}
