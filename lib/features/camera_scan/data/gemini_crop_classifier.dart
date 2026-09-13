import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/classifier_result.dart';

class GeminiCropClassifier {
  // TODO: Replace with your actual Gemini API Key from Google AI Studio
  static const _apiKey = 'YOUR_GEMINI_API_KEY';
  
  Future<ClassifierResult?> analyzeImage(String imagePath) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
       print('Gemini API key not configured. Falling back to offline model.');
       return null; // Return null so the hybrid model falls back to offline
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        )
      );

      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      
      final prompt = '''
You are an expert agricultural botanist and plant pathologist. 
Analyze the provided image of a plant/leaf. 
Return a JSON object with the exact following structure:
{
  "isHealthy": boolean (true if the plant looks perfectly healthy, false otherwise),
  "diseaseName": string (if not healthy, the precise name of the disease. If healthy, leave empty),
  "treatmentPlan": string (a step-by-step treatment plan to cure or prevent issues),
  "severity": string (e.g. "None", "Low", "Medium", "High"),
  "label": string (a short display title like "Healthy Tomato Leaf" or "Tomato Early Blight")
}
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await model.generateContent(content);
      
      if (response.text != null) {
        final jsonResult = jsonDecode(response.text!);
        
        return ClassifierResult(
          label: jsonResult['label'] ?? 'Unknown',
          confidence: 0.98, // High confidence for Generative AI result
          isHealthy: jsonResult['isHealthy'] ?? false,
          diseaseName: jsonResult['diseaseName'] ?? '',
          treatmentPlan: jsonResult['treatmentPlan'] ?? '',
          severity: jsonResult['severity'] ?? 'Unknown',
        );
      }
      return null;
    } catch (e) {
      print('Gemini API Error: $e');
      return null;
    }
  }
}
