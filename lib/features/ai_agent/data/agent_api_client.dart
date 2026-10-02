import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AgentApiClient {
  GenerativeModel? _model;

  GenerativeModel _getModel(String language) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    String languageInstruction = 'Respond in English.';
    if (language == 'si') {
      languageInstruction = 'Respond ONLY in Sinhala script (සිංහල). Never use Romanized Singlish.';
    } else if (language == 'ta') {
      languageInstruction = 'Respond ONLY in Tamil script (தமிழ்). Never use Romanized Tanglish.';
    }

    _model = GenerativeModel(
      model: 'gemini-3.8-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are AgriAI, a specialized agricultural and farming AI assistant.\n'
        'CRITICAL POLICY / MANDATORY REQUIREMENT:\n'
        '1. You MUST ONLY answer questions directly related to agriculture, farming, crops, plant diseases, pest management, soil health, fertilizers, irrigation, harvesting, farm machinery, weather impact on farming, agricultural economics, and farm livestock.\n'
        '2. If the user asks about ANYTHING ELSE that is NOT related to agriculture (such as politics, movies, entertainment, sports, computer programming, games, non-agricultural history, celebrities, relationships, general trivia, etc.), you MUST POLITELY REFUSE to answer.\n'
        '   - Refusal in English: "I am AgriAI, specialized only in agriculture and farming advice. Please ask me questions regarding crops, pests, soil, fertilizers, or farming practices."\n'
        '   - Refusal in Sinhala: "මම කෘෂිකාර්මික හා ගොවිතැන් උපදෙස් සඳහා පමණක් වෙන්වූ AgriAI වේ. කරුණාකර ඔබගේ වගාවන්, පළිබෝධ, පස, පොහොර හෝ ගොවිතැන් කටයුතු පිළිබඳ ප්‍රශ්න අසන්න."\n'
        '   - Refusal in Tamil: "நான் விவசாயம் மற்றும் பண்ணை சார்ந்த ஆலோசனைகளுக்கான AgriAI ஆவேன். தயவுசெய்து பயிர்கள், பூச்சிகள், மண், உரங்கள் அல்லது விவசாயம் பற்றிய கேள்விகளைக் கேளுங்கள்."\n'
        '3. Language Rule: $languageInstruction If the user speaks in Sinhala, reply in Sinhala script. If in Tamil, reply in Tamil script. If in English, reply in English.\n'
        '4. Provide practical, accurate, step-by-step agricultural advice with clear bullet points.'
      ),
    );
    return _model!;
  }

  Stream<String> streamChatAdvice({
    required String message,
    required String language,
    String? cropType,
    String? gpsZone,
    double? latitude,
    double? longitude,
  }) async* {
    final model = _getModel(language);

    final contextParts = <String>[];
    if (cropType != null && cropType.isNotEmpty) {
      contextParts.add('Target Crop: $cropType');
    }
    if (latitude != null && longitude != null) {
      contextParts.add('Location Coordinates: $latitude, $longitude');
    }
    if (gpsZone != null && gpsZone.isNotEmpty) {
      contextParts.add('Zone: $gpsZone');
    }

    String promptWithContext = message;
    if (contextParts.isNotEmpty) {
      promptWithContext = '[Farmer Context: ${contextParts.join(', ')}]\n\nQuestion: $message';
    }

    final responseStream = model.generateContentStream([
      Content.text(promptWithContext),
    ]);

    await for (final chunk in responseStream) {
      if (chunk.text != null && chunk.text!.isNotEmpty) {
        yield chunk.text!;
      }
    }
  }
}
