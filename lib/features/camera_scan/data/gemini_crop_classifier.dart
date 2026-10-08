import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/classifier_result.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiCropClassifier {
  static List<String> get _apiKeys {
    final keys = <String>[];
    final primary = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
    final backup = (dotenv.env['GEMINI_BACKUP_KEY'] ?? '').trim();
    if (primary.isNotEmpty && primary != 'YOUR_GEMINI_API_KEY') keys.add(primary);
    if (backup.isNotEmpty && backup != 'YOUR_GEMINI_API_KEY' && !keys.contains(backup)) keys.add(backup);
    return keys;
  }

  static bool get _isKeyConfigured => _apiKeys.isNotEmpty;

  // Prioritize active, responsive Gemini models
  static const List<String> supportedModels = [
    'gemini-flash-lite-latest',
    'gemini-3.5-flash-lite',
    'gemini-3.5-flash',
    'gemini-flash-latest',
    'gemini-3.8-flash',
    'gemini-3.7-flash',
  ];
  
  Future<ClassifierResult?> analyzeImage(String imagePath, {String language = 'en'}) async {
    if (!_isKeyConfigured) {
       debugPrint('Notice: GEMINI_API_KEY is not configured in .env. Falling back to offline scanner.');
       return null;
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();

      String langInstruction = 'Provide all text values in English.';
      if (language == 'si') {
        langInstruction = 'Provide all text fields ("label", "plantName", "cropType", "diseaseName", "symptoms", "treatmentPlan", "severity", "immediateActions", "organicRemedies", "chemicalRemedies", "irrigationTips", "preventiveTips") 100% EXCLUSIVELY in pure Sinhala script (සිංහල). Zero English words. Zero Singlish.';
      } else if (language == 'ta') {
        langInstruction = 'Provide all text fields 100% EXCLUSIVELY in pure Tamil script (தமிழ்). Zero English words. Zero Tanglish.';
      }

      final unrecognizedLabel = language == 'si'
          ? 'හඳුනාගත නොහැක / ශාකයක් නොවේ'
          : (language == 'ta' ? 'தாவரம் கண்டறியப்படவில்லை' : 'Not a Plant / Unrecognized Object');

      final rescanAdvice = language == 'si'
          ? 'මෙම ඡායාරූපයෙහි ශාකයක් හෝ බෝග පත්‍රයක් හඳුනාගත නොහැක (උදා: හෙල්මට්, වාහන, ඇඳුම් හෝ වෙනත් වස්තූන්). කරුණාකර සැබෑ ශාක පත්‍රයක් හෝ බෝගයක් ආලෝකය සහිතව ඡායාරූපගත කර නැවත ස්කෑන් කරන්න.'
          : (language == 'ta'
              ? 'இந்த படத்தில் தாவர இலை கண்டறியப்படவில்லை (ஹெல்மெட், பிற பொருள்கள்). தயவுசெய்து உண்மையான பயிரின் இலையை படம் எடுத்து மீண்டும் ஸ்கேன் செய்யவும்.'
              : 'The image does not contain an agricultural plant or crop leaf (e.g., helmet, furniture, or non-plant object). Please focus the camera on an actual crop leaf and rescan.');

      final prompt = '''
You are an expert plant pathologist, agricultural scientist, and botanist. 
Analyze the provided image in comprehensive agronomic detail.
Language Policy: $langInstruction

MANDATORY CRITICAL STEP 1 - OBJECT CLASSIFICATION:
Carefully determine if the subject in the photo is genuinely a plant, crop, leaf, flower, or agricultural produce.
- If the image depicts any non-plant item (such as a motorcycle helmet, face, clothing, furniture, tool, vehicle, pet, room, screen, wall, ground without vegetation), you MUST set "isPlant": false.
- NEVER fabricate, invent, or force a plant diagnosis for a non-plant object like a helmet!
- ONLY set "isPlant": true if there is a real botanical plant or crop in view.

If "isPlant" is false, return:
{
  "isPlant": false,
  "cropType": "",
  "plantName": "",
  "botanicalName": "",
  "isHealthy": false,
  "diseaseName": "",
  "symptoms": "",
  "severity": "None",
  "immediateActions": "",
  "organicRemedies": "",
  "chemicalRemedies": "",
  "irrigationTips": "",
  "preventiveTips": "",
  "treatmentPlan": "",
  "label": "$unrecognizedLabel"
}

If "isPlant" is true, analyze accurately:
{
  "isPlant": true,
  "cropType": string (the exact category and botanical family, e.g. "එළවළු බෝග (Solanaceae)", "ධාන්‍ය බෝග (Poaceae)", "පළතුරු බෝග (Musaceae)"),
  "plantName": string (the accurate common name of the crop, e.g. "තක්කාලි", "මිරිස්", "බණ්ඩක්කා", "කෙසෙල්", "වම්බටු", "වී", "පොල්"),
  "botanicalName": string (the accurate scientific botanical name, e.g. "Solanum lycopersicum", "Capsicum annuum"),
  "isHealthy": boolean (true if the foliage is completely healthy, vigorous and free of disease/pests; false if infected or deficient),
  "diseaseName": string (exact verified disease or pest diagnosis e.g. "අකල් අංගමාරය (Early Blight)", "පිටිපුස් රෝගය (Powdery Mildew)", "කොළ කොඩවීම (Leaf Curl)". If healthy, leave empty),
  "symptoms": string (detailed description of visual symptoms on the leaf: lesions, chlorosis, concentric rings, spots, wilting. If healthy, describe healthy leaf condition),
  "severity": string (${language == 'si' ? '"නැත", "අඩු", "මධ්‍යම", "ඉහළ"' : (language == 'ta' ? '"இல்லை", "குறைவு", "நடுத்தரம்", "அதிகம்"' : '"None", "Low", "Moderate", "High"')}),
  "immediateActions": string (urgent field actions to take immediately: pruning infected foliage, isolating plant, burning debris),
  "organicRemedies": string (natural organic remedies with exact preparation and dosages: neem oil spray, wood ash, compost tea, baking soda solution),
  "chemicalRemedies": string (recommended chemical controls and fungicide/insecticide with exact dosages per tank e.g. Mancozeb, Chlorothalonil, Copper Oxychloride),
  "irrigationTips": string (watering recommendations: avoid overhead watering, drip irrigation, water only at root level in early morning),
  "preventiveTips": string (long-term crop rotation, resistant varieties, soil solarization, spacing),
  "treatmentPlan": string (summary of comprehensive step-by-step numbered instructions),
  "label": string (short display title e.g. "තක්කාලි අකල් අංගමාරය" or "නිරෝගී තක්කාලි පත්‍රය")
}

Return ONLY valid JSON matching the structure without markdown blocks.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      GenerateContentResponse? response;

      keyLoop:
      for (final activeKey in _apiKeys) {
        for (final modelName in supportedModels) {
          try {
            final model = GenerativeModel(
              model: modelName,
              apiKey: activeKey,
              generationConfig: GenerationConfig(
                responseMimeType: 'application/json',
              ),
            );
            
            // Timeout per model attempt to prevent hanging on congested models
            final res = await model.generateContent(content).timeout(const Duration(seconds: 12));
            if (res.text != null && res.text!.trim().isNotEmpty) {
              response = res;
              debugPrint('Gemini classification succeeded using model: $modelName');
              break keyLoop;
            }
          } catch (e) {
            debugPrint('Model $modelName notice: $e. Trying next model...');
          }
        }
      }
      
      if (response != null && response.text != null) {
        String jsonString = response.text!.trim();
        jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final jsonResult = jsonDecode(jsonString);
        
        final isPlant = jsonResult['isPlant'] == true;
        if (!isPlant) {
           return ClassifierResult(
             label: unrecognizedLabel,
             confidence: 0.0,
             isHealthy: false,
             diseaseName: '',
             treatmentPlan: rescanAdvice,
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

        final isHealthy = jsonResult['isHealthy'] == true;
        final plantName = (jsonResult['plantName'] ?? '').toString().trim();
        final cropType = (jsonResult['cropType'] ?? '').toString().trim();
        final botanicalName = (jsonResult['botanicalName'] ?? '').toString().trim();
        final diseaseName = (jsonResult['diseaseName'] ?? '').toString().trim();
        final symptoms = (jsonResult['symptoms'] ?? '').toString().trim();
        final immediateActions = (jsonResult['immediateActions'] ?? '').toString().trim();
        final organicRemedies = (jsonResult['organicRemedies'] ?? '').toString().trim();
        final chemicalRemedies = (jsonResult['chemicalRemedies'] ?? '').toString().trim();
        final irrigationTips = (jsonResult['irrigationTips'] ?? '').toString().trim();
        final preventiveTips = (jsonResult['preventiveTips'] ?? '').toString().trim();
        final treatmentPlan = (jsonResult['treatmentPlan'] ?? '').toString().trim();
        final severity = (jsonResult['severity'] ?? (language == 'si' ? 'මධ්‍යම' : 'Moderate')).toString().trim();
        
        final String label;
        if (jsonResult['label'] != null && jsonResult['label'].toString().trim().isNotEmpty) {
          label = jsonResult['label'].toString().trim();
        } else if (isHealthy) {
          label = language == 'si' ? 'නිරෝගී $plantName' : 'Healthy $plantName';
        } else if (diseaseName.isNotEmpty) {
          label = diseaseName;
        } else {
          label = plantName;
        }

        return ClassifierResult(
          label: label,
          confidence: 0.96,
          isHealthy: isHealthy,
          diseaseName: isHealthy ? '' : diseaseName,
          treatmentPlan: treatmentPlan.isNotEmpty ? treatmentPlan : immediateActions,
          severity: isHealthy ? (language == 'si' ? 'නැත' : 'None') : severity,
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

