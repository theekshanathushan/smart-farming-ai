import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/classifier_result.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiCropClassifier {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY';
  
  Future<ClassifierResult?> analyzeImage(String imagePath, {String language = 'en'}) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
       print('Gemini API key not configured. Falling back to offline model.');
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

      GenerateContentResponse response;
      try {
        final model = GenerativeModel(
          model: 'gemini-3.1-flash-lite',
          apiKey: _apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );
        response = await model.generateContent(content);
      } catch (e) {
        // Fallback to gemini-3-flash-preview if primary model fails
        final fallbackModel = GenerativeModel(
          model: 'gemini-3-flash-preview',
          apiKey: _apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );
        response = await fallbackModel.generateContent(content);
      }
      
      if (response.text != null) {
        String jsonString = response.text!;
        // Clean markdown backticks if Gemini includes them
        jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final jsonResult = jsonDecode(jsonString);
        
        final isPlant = jsonResult['isPlant'] ?? true;
        if (!isPlant) {
           return ClassifierResult(
             label: 'Unrecognized / Not a clear plant',
             confidence: 0.98,
             isHealthy: false,
             diseaseName: '',
             treatmentPlan: '',
             severity: 'None'
           );
        }

        return ClassifierResult(
          label: jsonResult['label'] ?? 'Unknown',
          confidence: 0.98, // High confidence for Generative AI result
          isHealthy: jsonResult['isHealthy'] ?? false,
          diseaseName: jsonResult['diseaseName'] ?? '',
          treatmentPlan: jsonResult['treatmentPlan'] ?? '',
          severity: jsonResult['severity'] ?? 'Unknown',
        );
      } else {
        return ClassifierResult(
          label: 'API Blocked Response',
          confidence: 0.0,
          isHealthy: false,
          diseaseName: 'No Text Returned',
          treatmentPlan: 'Gemini returned an empty response. Finish Reason: \${response.candidates.isNotEmpty ? response.candidates.first.finishReason : "Unknown"}',
          severity: 'High'
        );
      }
    } catch (e) {
      print('Gemini API Error: $e');
      return ClassifierResult(
        label: 'API/Network Error',
        confidence: 0.0,
        isHealthy: false,
        diseaseName: 'Connection Failed',
        treatmentPlan: 'Error Details:\n$e',
        severity: 'High'
      );
    }
  }
}
