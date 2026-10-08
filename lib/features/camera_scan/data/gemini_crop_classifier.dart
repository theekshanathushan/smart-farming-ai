import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/classifier_result.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiCropClassifier {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY';

  static bool get _isKeyConfigured {
    final key = _apiKey.trim();
    return key.isNotEmpty && key != 'YOUR_GEMINI_API_KEY';
  }

  // Exact supported models requested by user, tried in intelligent priority order
  static const List<String> supportedModels = [
    'gemini-3.8-flash',
    'gemini-3.6-flash',
    'gemini-3.7-flash',
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-2.5-flash-lite',
    'gemini-3-flash',
    'gemini-3.1-flash-lite',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-flash-latest',
  ];
  
  Future<ClassifierResult?> analyzeImage(String imagePath, {String language = 'en'}) async {
    if (!_isKeyConfigured) {
       debugPrint('Notice: GEMINI_API_KEY is not configured in .env. Falling back to offline scanner.');
       return null;
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      String langInstruction = 'Provide all text values in English.';
      if (language == 'si') {
        langInstruction = 'Provide all text fields ("label", "plantName", "cropType", "diseaseName", "symptoms", "treatmentPlan", "severity", "immediateActions", "organicRemedies", "chemicalRemedies", "irrigationTips", "preventiveTips") 100% EXCLUSIVELY in pure Sinhala script (සිංහල). Zero English words. Zero Singlish.';
      } else if (language == 'ta') {
        langInstruction = 'Provide all text fields 100% EXCLUSIVELY in pure Tamil script (தமிழ்). Zero English words. Zero Tanglish.';
      }

      final unrecognizedLabel = language == 'si'
          ? 'හඳුනාගත නොහැක / ශාක පත්‍රයක් නොවේ'
          : (language == 'ta' ? 'அடையாளம் காண முடியவில்லை' : 'Unrecognized / Not a plant');

      final prompt = '''
You are an expert plant pathologist, agricultural scientist, and botanist. 
Analyze the provided crop image in comprehensive agronomic detail.
Language Policy: $langInstruction

Return a JSON object with the exact following structure without markdown blocks:
{
  "isPlant": boolean (true if image contains a plant, leaf, crop, or fruit; false otherwise),
  "cropType": string (the category and family of crop, e.g. "එළවළු බෝග (Solanaceae)", "පළතුරු බෝග", "ධාන්‍ය බෝග", "කුළුබඩු බෝග"),
  "plantName": string (the common name of the plant/crop, e.g. "තක්කාලි", "මිරිස්", "බණ්ඩක්කා", "කෙසෙල්", "වම්බටු"),
  "botanicalName": string (the scientific/botanical name, e.g. "Solanum lycopersicum", "Capsicum annuum"),
  "isHealthy": boolean (true if perfectly healthy, false if diseased or pest attacked),
  "diseaseName": string (exact name of the disease or pest and pathogen type e.g. "තක්කාලි අකල් අංගමාරය (Early Blight - Alternaria solani)". If healthy or not a plant, leave empty),
  "symptoms": string (detailed description of visual symptoms on the leaf: lesions, yellowing chlorosis, concentric rings, spots, wilting),
  "severity": string (${language == 'si' ? '"නැත", "අඩු", "මධ්‍යම", "ඉහළ"' : (language == 'ta' ? '"இல்லை", "குறைவு", "நடுத்தரம்", "அதிகம்"' : '"None", "Low", "Moderate", "High"')}),
  "immediateActions": string (urgent field actions to take immediately: pruning infected foliage, isolating plant, burning debris),
  "organicRemedies": string (natural organic remedies with exact preparation and dosages: neem oil spray, wood ash, compost tea, baking soda solution),
  "chemicalRemedies": string (recommended chemical controls and fungicide/insecticide with exact dosages per tank e.g. Mancozeb, Chlorothalonil, Copper Oxychloride),
  "irrigationTips": string (watering recommendations: avoid overhead watering, drip irrigation, water only at root level in early morning),
  "preventiveTips": string (long-term crop rotation, resistant varieties, soil solarization, spacing),
  "treatmentPlan": string (summary of comprehensive step-by-step numbered instructions),
  "label": string (short display title e.g. "තක්කාලි අකල් අංගමාරය" or "නිරෝගී තක්කාලි පත්‍රය")
}
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      GenerateContentResponse? response;

      for (final modelName in supportedModels) {
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: _apiKey,
            generationConfig: GenerationConfig(
              responseMimeType: 'application/json',
            ),
          );
          response = await model.generateContent(content);
          if (response.text != null && response.text!.isNotEmpty) {
            debugPrint('Gemini classification succeeded using model: $modelName');
            break;
          }
        } catch (e) {
          debugPrint('Model $modelName notice: $e. Trying next model...');
        }
      }
      
      if (response != null && response.text != null) {
        String jsonString = response.text!;
        jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final jsonResult = jsonDecode(jsonString);
        
        final isPlant = jsonResult['isPlant'] ?? true;
        if (!isPlant) {
           return ClassifierResult(
             label: unrecognizedLabel,
             confidence: 0.98,
             isHealthy: false,
             diseaseName: '',
             treatmentPlan: '',
             severity: language == 'si' ? 'නැත' : (language == 'ta' ? 'இல்லை' : 'None'),
             isPlant: false,
             plantName: '',
             cropType: '',
             botanicalName: '',
             symptoms: '',
             immediateActions: '',
             organicRemedies: '',
             chemicalRemedies: '',
             preventiveTips: '',
           );
        }

        final isHealthy = jsonResult['isHealthy'] ?? false;
        final plantName = jsonResult['plantName'] ?? (language == 'si' ? 'ගොවිපළ බෝගය' : 'Crop');
        final cropType = jsonResult['cropType'] ?? (language == 'si' ? 'කෘෂිකාර්මික බෝග' : 'Agricultural Crop');
        final botanicalName = jsonResult['botanicalName'] ?? '';
        final diseaseName = jsonResult['diseaseName'] ?? '';
        final symptoms = jsonResult['symptoms'] ?? '';
        final immediateActions = jsonResult['immediateActions'] ?? '';
        final organicRemedies = jsonResult['organicRemedies'] ?? '';
        final chemicalRemedies = jsonResult['chemicalRemedies'] ?? '';
        final irrigationTips = jsonResult['irrigationTips'] ?? '';
        final preventiveTips = jsonResult['preventiveTips'] ?? '';
        final treatmentPlan = jsonResult['treatmentPlan'] ?? '';
        final severity = jsonResult['severity'] ?? (language == 'si' ? 'සාමාන්‍ය' : 'Moderate');
        final label = jsonResult['label'] ?? (diseaseName.isNotEmpty ? diseaseName : plantName);

        return ClassifierResult(
          label: label,
          confidence: 0.98,
          isHealthy: isHealthy,
          diseaseName: diseaseName,
          treatmentPlan: treatmentPlan.isNotEmpty ? treatmentPlan : immediateActions,
          severity: severity,
          plantName: plantName,
          cropType: cropType,
          botanicalName: botanicalName,
          symptoms: symptoms,
          immediateActions: immediateActions,
          organicRemedies: organicRemedies,
          chemicalRemedies: chemicalRemedies,
          preventiveTips: preventiveTips.isNotEmpty ? preventiveTips : irrigationTips,
          isPlant: true,
        );
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Gemini Crop Classifier Error: $e');
      return null;
    }
  }
}
