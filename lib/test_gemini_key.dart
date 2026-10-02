import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  // Read from .env file directly for the dart script
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('Error: .env file not found.');
    return;
  }
  final envContent = await envFile.readAsString();
  final apiKeyLine = envContent.split('\n').firstWhere((line) => line.startsWith('GEMINI_API_KEY='), orElse: () => '');
  final apiKey = apiKeyLine.replaceFirst('GEMINI_API_KEY=', '').trim();

  if (apiKey.isEmpty) {
    print('Error: GEMINI_API_KEY not found in .env');
    return;
  }
  
  try {
    final model = GenerativeModel(
      model: 'gemini-3.8-flash',
      apiKey: apiKey,
    );

    final prompt = 'Respond with a simple hello world';
    final content = [Content.text(prompt)];

    print('Testing Gemini API key...');
    final response = await model.generateContent(content);
    print('Success! Response: ${response.text}');
  } catch (e) {
    print('Error caught: $e');
  }
}
