import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/classifier_result.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiCropClassifier {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY';

  static bool get _isKeyValid {
    final key = _apiKey.trim();
    return key.isNotEmpty && key != 'YOUR_GEMINI_API_KEY' && key.startsWith('AIzaSy');
  }
  
  Future<ClassifierResult?> analyzeImage(String imagePath, {String language = 'en'}) async {
    if (!_isKeyValid) {
       debugPrint('Gemini API key is not a valid Google AI Studio key (must start with AIzaSy). Seamlessly falling back to offline CV model.');
       return null; // Return null so the hybrid model falls back to offline
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      String langInstruction = 'Provide all text values in English.';
      if (language == 'si') {
        langInstruction = 'Provide all text fields ("label", "diseaseName", "treatmentPlan", "severity") 100% EXCLUSIVELY in pure Sinhala script (සිංහල). Zero English words. Zero Singlish.';
      } else if (language == 'ta') {
        langInstruction = 'Provide all text fields ("label", "diseaseName", "treatmentPlan", "severity") 100% EXCLUSIVELY in pure Tamil script (தமிழ்). Zero English words. Zero Tanglish.';
      }

      final unrecognizedLabel = language == 'si'
          ? 'හඳුනාගත නොහැක / ශාක පත්‍රයක් නොවේ'
          : (language == 'ta' ? 'அடையாளம் காண முடியவில்லை' : 'Unrecognized / Not a plant');

      final prompt = '''
You are an expert agricultural botanist and plant pathologist. 
Analyze the provided image. 
Language Policy: $langInstruction
1. If the image is NOT a plant or leaf (e.g. it's a bottle, person, car, etc.), you MUST set "isPlant" to false, "label" to "$unrecognizedLabel", and keep the rest empty.
2. If it IS a plant, determine if it is perfectly healthy or diseased.
Return a JSON object with the exact following structure without markdown blocks:
{
  "isPlant": boolean (true if it's a plant/leaf, false otherwise),
  "isHealthy": boolean (true if the plant looks perfectly healthy, false if diseased. Ignored if not a plant),
  "diseaseName": string (if diseased, the precise name of the disease. If healthy or not a plant, leave empty),
  "treatmentPlan": string (a step-by-step treatment plan if diseased. If healthy, provide general care tips. If not a plant, leave empty),
  "severity": string (e.g. ${language == 'si' ? '"නැත", "අඩු", "මධ්‍යම", "ඉහළ"' : (language == 'ta' ? '"இல்லை", "குறைவு", "நடுத்தரம்", "அதிகம்"' : '"None", "Low", "Medium", "High"')}),
  "label": string (a short display title like ${language == 'si' ? '"නිරෝගී තක්කාලි කොළය", "තක්කාලි අකල් අංගමාරය"' : (language == 'ta' ? '"ஆரோக்கியமான தக்காளி இலை", "தக்காளி கருகல் நோய்"' : '"Healthy Tomato Leaf", "Tomato Early Blight"')})
}
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      GenerateContentResponse? response;
      final modelsToTry = ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-flash-latest'];

      for (final modelName in modelsToTry) {
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
            break;
          }
        } catch (e) {
          debugPrint('Notice: Model $modelName failed: $e. Trying next model...');
        }
      }
      
      if (response != null && response.text != null) {
        String jsonString = response.text!;
        // Clean markdown backticks if Gemini includes them
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
             severity: language == 'si' ? 'නැත' : (language == 'ta' ? 'இல்லை' : 'None')
           );
        }

        return ClassifierResult(
          label: jsonResult['label'] ?? (language == 'si' ? 'නොදන්නා බෝගය' : (language == 'ta' ? 'தெரியாத பயிர்' : 'Unknown Crop')),
          confidence: 0.98, // High confidence for Generative AI result
          isHealthy: jsonResult['isHealthy'] ?? false,
          diseaseName: jsonResult['diseaseName'] ?? '',
          treatmentPlan: jsonResult['treatmentPlan'] ?? '',
          severity: jsonResult['severity'] ?? (language == 'si' ? 'සාමාන්‍ය' : (language == 'ta' ? 'சாதாரண' : 'Moderate')),
        );
      } else {
        return null; // Return null so offline model takes over
      }
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      return null; // Return null to seamlessly fallback to offline CV engine
    }
  }
}
