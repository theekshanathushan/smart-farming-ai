import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image/image.dart' as img;
import '../domain/classifier_result.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiCropClassifier {
  static List<String> get _apiKeys {
    final keys = <String>[];
    final primary = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
    final backup = (dotenv.env['GEMINI_BACKUP_KEY'] ?? '').trim();

    if (primary.isNotEmpty && primary != 'YOUR_GEMINI_API_KEY') {
      keys.add(primary);
    }
    if (backup.isNotEmpty &&
        backup != 'YOUR_GEMINI_API_KEY' &&
        !keys.contains(backup)) {
      keys.add(backup);
    }
    return keys;
  }


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
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;
      Uint8List bytes = await file.readAsBytes();

      // Optimize image payload size so upload takes < 1 second and never drops connection
      try {
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          // Resize if large
          final maxDim = decoded.width > decoded.height ? decoded.width : decoded.height;
          final img.Image processed;
          if (maxDim > 800) {
            processed = img.copyResize(decoded, width: 800, height: 800, maintainAspect: true);
          } else {
            processed = decoded;
          }
          bytes = Uint8List.fromList(img.encodeJpg(processed, quality: 80));
        }
      } catch (e) {
        debugPrint('Image compression notice: $e');
      }

      String langInstruction;
      String exampleCropType;
      String examplePlantName;
      String exampleDiseaseName;
      String severityOptions;
      String exampleLabel;

      if (language == 'si') {
        langInstruction = 'Provide all text fields ("label", "plantName", "cropType", "diseaseName", "symptoms", "treatmentPlan", "severity", "immediateActions", "organicRemedies", "chemicalRemedies", "irrigationTips", "preventiveTips") 100% EXCLUSIVELY in pure Sinhala script (සිංහල). Zero English words. Zero Singlish. Zero Tamil.';
        exampleCropType = 'string (උදා: "එළවළු බෝගය", "ධාන්‍ය බෝගය", "පළතුරු බෝගය")';
        examplePlantName = 'string (උදා: "තක්කාලි", "මිරිස්", "බණ්ඩක්කා", "කෙසෙල්", "වම්බටු", "වී")';
        exampleDiseaseName = 'string (උදා: "අකල් අංගමාරය", "පිටිපුස් රෝගය", "කොළ කොඩවීම". නිරෝගී නම් හිස්ව තබන්න)';
        severityOptions = '"නැත", "අඩු", "මධ්‍යම", "ඉහළ"';
        exampleLabel = 'string (උදා: "තක්කාලි අකල් අංගමාරය" හෝ "නිරෝගී තක්කාලි පත්‍රය")';
      } else if (language == 'ta') {
        langInstruction = 'Provide all text fields ("label", "plantName", "cropType", "diseaseName", "symptoms", "treatmentPlan", "severity", "immediateActions", "organicRemedies", "chemicalRemedies", "irrigationTips", "preventiveTips") 100% EXCLUSIVELY in pure Tamil script (தமிழ்). Zero English words. Zero Tanglish. Zero Sinhala.';
        exampleCropType = 'string (எ.கா. "காய்கறிப் பயிர்", "தானியப் பயிர்", "பழப் பயிர்")';
        examplePlantName = 'string (எ.கா. "தக்காளி", "மிளகாய்", "வெண்டைக்காய்", "வாழை", "கத்தரிக்காய்", "நெல்")';
        exampleDiseaseName = 'string (எ.கா. "ஆரம்பகால கருகல் நோய்", "சாம்பல் நோய்", "இலை சுருள் நோய்". ஆரோக்கியமானதாயின் காலியாக விடவும்)';
        severityOptions = '"இல்லை", "குறைவு", "நடுத்தரம்", "அதிகம்"';
        exampleLabel = 'string (எ.கா. "தக்காளி ஆரம்பகால கருகல்" அல்லது "ஆரோக்கியமான தக்காளி இலை")';
      } else {
        langInstruction = 'Provide all text fields ("label", "plantName", "cropType", "diseaseName", "symptoms", "treatmentPlan", "severity", "immediateActions", "organicRemedies", "chemicalRemedies", "irrigationTips", "preventiveTips") 100% EXCLUSIVELY in clean, professional English. Do not mix any Sinhala or Tamil words.';
        exampleCropType = 'string (e.g. "Vegetable Crop", "Cereal Crop", "Fruit Crop")';
        examplePlantName = 'string (e.g. "Tomato", "Chilli", "Okra", "Banana", "Eggplant", "Paddy")';
        exampleDiseaseName = 'string (e.g. "Early Blight", "Powdery Mildew", "Leaf Curl". If healthy, leave empty)';
        severityOptions = '"None", "Low", "Moderate", "High"';
        exampleLabel = 'string (e.g. "Tomato Early Blight" or "Healthy Tomato Leaf")';
      }

      final unrecognizedLabel = language == 'si'
          ? 'හඳුනාගත නොහැක / ශාකයක් නොවේ'
          : (language == 'ta' ? 'தாவரம் கண்டறியப்படவில்லை' : 'Not a Plant / Unrecognized Object');

      final rescanAdvice = language == 'si'
          ? 'කරුණාකර පැහැදිලි ආලෝකයක් සහිත ස්ථානයකදී බෝගයේ හෝ පත්‍රයේ ඡායාරූපයක් නැවත ස්කෑන් කරන්න.'
          : (language == 'ta'
              ? 'தயவுசெய்து தெளிவான வெளிச்சத்தில் பயிர் அல்லது இலையின் படத்தை மீண்டும் ஸ்கேன் செய்யவும்.'
              : 'Please take a clear photo of an actual plant leaf or crop in good lighting.');

      final prompt = '''
You are an expert plant pathologist, agricultural scientist, and botanist. 
Analyze the provided image in comprehensive agronomic detail.
Language Policy: $langInstruction

MANDATORY CRITICAL STEP 1 - PLANT DETECTION TEST:
Carefully inspect whether the image contains a genuine biological plant, crop, leaf, flower, or fruit.
- If the image shows ANY non-plant manufactured object (such as a cream bottle, cosmetic container, shampoo bottle, plastic bottle, can, glass, motorcycle helmet, electronic device, furniture, human face, hand, clothing, floor, room, wall, background without plants), you MUST set "isPlant": false.
- NEVER hypothesize, imagine, or assume that a bottle, container, or helmet is a plant or leaf!
- ONLY set "isPlant": true if there is an actual live botanical plant, leaf, crop, or produce clearly visible.

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
  "cropType": $exampleCropType,
  "plantName": $examplePlantName,
  "botanicalName": string (the accurate scientific botanical name, e.g. "Solanum lycopersicum", "Capsicum annuum"),
  "isHealthy": boolean (true if the foliage is completely healthy, vigorous and free of disease/pests; false if infected or deficient),
  "diseaseName": $exampleDiseaseName,
  "symptoms": string (detailed description of visual symptoms on the leaf: lesions, chlorosis, concentric rings, spots, wilting. If healthy, describe healthy leaf condition),
  "severity": string ($severityOptions),
  "immediateActions": string (urgent field actions to take immediately: pruning infected foliage, isolating plant, burning debris),
  "organicRemedies": string (natural organic remedies with exact preparation and dosages),
  "chemicalRemedies": string (recommended chemical controls and fungicide/insecticide with exact dosages per tank),
  "irrigationTips": string (watering recommendations: avoid overhead watering, drip irrigation, water only at root level in early morning),
  "preventiveTips": string (long-term crop rotation, resistant varieties, soil solarization, spacing),
  "treatmentPlan": string (summary of comprehensive step-by-step numbered instructions),
  "label": $exampleLabel
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

