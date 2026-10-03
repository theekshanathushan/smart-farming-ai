import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AgentApiClient {
  GenerativeModel _getModel(String language, {String modelName = 'gemini-flash-latest'}) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    String languageInstruction = 'Respond in English.';
    if (language == 'si') {
      languageInstruction = 'Respond ONLY in Sinhala script (සිංහල). Never use Romanized Singlish.';
    } else if (language == 'ta') {
      languageInstruction = 'Respond ONLY in Tamil script (தமிழ்). Never use Romanized Tanglish.';
    }

    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are AgriAI, a specialized agricultural and farming AI assistant.\n'
        'CRITICAL POLICY / MANDATORY REQUIREMENT:\n'
        '1. You MUST ONLY answer questions directly related to agriculture, farming, crops, plant diseases, pest management, soil health, fertilizers, irrigation, harvesting, farm machinery, weather impact on farming, agricultural economics, and farm livestock.\n'
        '2. If the user asks about ANYTHING ELSE that is NOT related to agriculture (such as politics, movies, entertainment, sports, computer programming, games, non-agricultural history, celebrities, relationships, general trivia, greetings without agriculture context, etc.), you MUST POLITELY REFUSE to answer.\n'
        '   - Refusal in English: "I am AgriAI, specialized only in agriculture and farming advice. Please ask me questions regarding crops, pests, soil, fertilizers, or farming practices."\n'
        '   - Refusal in Sinhala: "මම කෘෂිකාර්මික හා ගොවිතැන් උපදෙස් සඳහා පමණක් වෙන්වූ AgriAI වේ. කරුණාකර ඔබගේ වගාවන්, පළිබෝධ, පස, පොහොර හෝ ගොවිතැන් කටයුතු පිළිබඳ ප්‍රශ්න අසන්න."\n'
        '   - Refusal in Tamil: "நான் விவசாயம் மற்றும் பண்ணை சார்ந்த ஆலோசனைகளுக்கான AgriAI ஆவேன். தயவுசெய்து பயிர்கள், பூச்சிகள், மண், உரங்கள் அல்லது விவசாயம் பற்றிய கேள்விகளைக் கேளுங்கள்."\n'
        '3. Language Rule: $languageInstruction If the user speaks in Sinhala, reply in Sinhala script. If in Tamil, reply in Tamil script. If in English, reply in English.\n'
        '4. CLARITY & POINT-BY-POINT STRUCTURE (MANDATORY):\n'
        '   - ALWAYS organize your explanation clearly POINT BY POINT using bold numbers (1., 2., 3.) or bullet points (•).\n'
        '   - Do NOT write dense or cluttered walls of paragraphs.\n'
        '   - Structure your advice with clean, bold section headers and emojis:\n'
        '     ### 🔍 1. Diagnosis & Symptoms (හඳුනාගැනීම / அறிகுறிகள்)\n'
        '     ### ⚠️ 2. Causes & Risk Factors (හේතු / காரணங்கள்)\n'
        '     ### 🌿 3. Immediate Organic & Natural Remedies (ස්වාභාවික ප්‍රතිකාර / இயற்கை முறைகள்)\n'
        '     ### 🧪 4. Chemical or Fertilizer Controls (රසායනික හෝ පොහොර / இரசாயன & உர தீர்வுகள்)\n'
        '     ### 🛡️ 5. Long-Term Prevention & Field Care (වැළැක්වීමේ උපදෙස් / தடுப்பு முறைகள்)\n'
        '   - Under each section, provide specific, concise, numbered or bulleted actionable steps.\n'
        '   - Highlight all key measurements, dosages, application times, and crop names in bold for quick readability in the field.'
      ),
    );
  }

  Stream<String> streamChatAdvice({
    required String message,
    required String language,
    String? cropType,
    String? gpsZone,
    double? latitude,
    double? longitude,
  }) async* {
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

    // Try primary model: gemini-flash-latest
    bool streamStarted = false;
    try {
      final primaryModel = _getModel(language, modelName: 'gemini-flash-latest');
      final responseStream = primaryModel.generateContentStream([
        Content.text(promptWithContext),
      ]);

      await for (final chunk in responseStream) {
        if (chunk.text != null && chunk.text!.isNotEmpty) {
          streamStarted = true;
          yield chunk.text!;
        }
      }
    } catch (e) {
      // If primary model has 503 high demand or fails before streaming, fallback to gemini-flash-lite-latest
      if (!streamStarted) {
        try {
          final fallbackModel = _getModel(language, modelName: 'gemini-flash-lite-latest');
          final fallbackStream = fallbackModel.generateContentStream([
            Content.text(promptWithContext),
          ]);
          await for (final chunk in fallbackStream) {
            if (chunk.text != null && chunk.text!.isNotEmpty) {
              yield chunk.text!;
            }
          }
        } catch (fallbackError) {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }
}
