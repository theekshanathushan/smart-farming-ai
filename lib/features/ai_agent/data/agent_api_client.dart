import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AgentChatTurn {
  final String text;
  final bool isUser;

  const AgentChatTurn({required this.text, required this.isUser});
}

class AgentApiClient {
  GenerativeModel _getModel(String language, {String modelName = 'gemini-3.1-flash-lite'}) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      throw Exception('Gemini API Key is missing. Please set GEMINI_API_KEY in .env file.');
    }

    String languageRule;
    String refusalText;
    String headersTemplate;

    if (language == 'si') {
      languageRule =
          '🛑 අනිවාර්ය භාෂා ප්‍රතිපත්තිය (100% සිංහල පමණි - ZERO ENGLISH & ZERO SINGLISH):\n'
          '1. පරිශීලකයා සිංහල භාෂාව තෝරාගෙන ඇත.\n'
          '2. ඔබගේ සමස්ත පිළිතුරෙහි සෑම වචනයක්ම, මාතෘකාවක්ම, උපදෙසක්ම සහ පැහැදිලි කිරීමක්ම 100% ක් පිරිසිදු සිංහල අක්ෂරවලින් (Sinhala script) පමණක්ම ලිවිය යුතුය.\n'
          '3. කිසිදු ඉංග්‍රීසි වචනයක් (No English words), ඉංග්‍රීසි මාතෘකාවක් හෝ ඉංග්‍රීසි අකුරු භාවිත නොකරන්න.\n'
          '4. ඉංග්‍රීසි අකුරින් ලියන සිංග්ලිෂ් (Singlish) සම්පූර්ණයෙන්ම තහනම්ය.\n'
          '5. පරිශීලකයා ප්‍රශ්නය ඉංග්‍රීසියෙන් හෝ සිංග්ලිෂ් වලින් ඇසුවද, ඔබ පිළිතුරු දිය යුත්තේ 100% ක් පිරිසිදු සිංහල අක්ෂර වලින් පමණි.\n'
          '6. රසායනික හෝ විද්‍යාත්මක නම් පවා සිංහල අකුරින් ලියන්න (උදා: යූරියා, මැන්කොසෙබ්, නයිට්‍රජන්, මිලිලීටර්, ග්‍රෑම්).';
      refusalText =
          '"මම කෘෂිකාර්මික හා ගොවිතැන් උපදෙස් සඳහා පමණක් වෙන්වූ AgriAI වේ. කරුණාකර ඔබගේ වගාවන්, පළිබෝධ, පස, පොහොර හෝ ගොවිතැන් කටයුතු පිළිබඳ ප්‍රශ්න පමණක් අසන්න."';
      headersTemplate =
          '     ### 🔍 1. රෝග විනිශ්චය සහ ප්‍රධාන ලක්ෂණ\n'
          '     ### ⚠️ 2. හේතු සහ අවදානම් සාධක\n'
          '     ### 🌿 3. ක්ෂණික කාබනික හා ස්වාභාවික පිළියම්\n'
          '     ### 🧪 4. රසායනික පාලනය සහ නිර්දේශිත මාත්‍රා\n'
          '     ### 🛡️ 5. දීර්ඝකාලීන ක්ෂේත්‍ර රැකවරණය සහ වැළැක්වීමේ පියවර';
    } else if (language == 'ta') {
      languageRule =
          '🛑 கட்டாய மொழி விதி (100% தமிழ் மட்டுமே - ZERO ENGLISH & ZERO TANGLISH):\n'
          '1. பயனர் தமிழ் மொழியைத் தேர்ந்தெடுத்துள்ளார்.\n'
          '2. உங்கள் பதில் முழுவதும் 100% தூய தமிழ் எழுத்துக்களில் (Tamil script) மட்டுமே இருக்க வேண்டும்.\n'
          '3. எந்தவொரு ஆங்கில வார்த்தையையும் (No English words) அல்லது ஆங்கில எழுத்துக்களையும் பயன்படுத்த வேண்டாம்.\n'
          '4. பயனர் ஆங்கிலத்தில் அல்லது தங்கிலிஷில் கேட்டாலும், நீங்கள் தமிழில் மட்டுமே பதிலளிக்க வேண்டும்.';
      refusalText =
          '"நான் விவசாயம் மற்றும் பண்ணை சார்ந்த ஆலோசனைகளுக்கான AgriAI ஆவேன். தயவுசெய்து பயிர்கள், பூச்சிகள், மண், உரங்கள் அல்லது விவசாயம் பற்றிய கேள்விகளை மட்டும் கேளுங்கள்."';
      headersTemplate =
          '     ### 🔍 1. நோய் கண்டறிதல் மற்றும் முக்கிய அறிகுறிகள்\n'
          '     ### ⚠️ 2. காரணங்கள் மற்றும் ஆபத்து காரணிகள்\n'
          '     ### 🌿 3. உடனடி இயற்கை மற்றும் உயிரியல் தீர்வுகள்\n'
          '     ### 🧪 4. இரசாயனக் கட்டுப்பாடு மற்றும் பரிந்துரைக்கப்பட்ட அளவுகள்\n'
          '     ### 🛡️ 5. நீண்ட கால களப் பராமரிப்பு மற்றும் தடுப்பு முறைகள்';
    } else {
      languageRule =
          'Respond 100% in clear, professional English. Do not mix other languages.';
      refusalText =
          '"I am AgriAI, specialized strictly in agriculture and farming advice. I cannot answer non-agricultural questions. Please ask me questions regarding crops, pests, soil, fertilizers, or farming practices."';
      headersTemplate =
          '     ### 🔍 1. Diagnosis & Key Symptoms\n'
          '     ### ⚠️ 2. Causes & Risk Factors\n'
          '     ### 🌿 3. Immediate Organic & Natural Remedies\n'
          '     ### 🧪 4. Chemical Controls & Recommended Dosages\n'
          '     ### 🛡️ 5. Long-Term Field Care & Preventive Practices';
    }

    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are AgriAI (කෘෂි AI), a specialized and strictly dedicated agricultural, farming, and plant health AI assistant.\n\n'
        '🛑 CRITICAL MANDATORY TOPIC RESTRICTION RULE (ABSOLUTE POLICY - ZERO EXCEPTIONS):\n'
        '1. You MUST ONLY and EXCLUSIVELY answer questions directly related to agriculture, farming, crops, plant diseases, pest management, soil health, fertilizers (chemical and organic), irrigation techniques, harvesting, farm machinery, livestock, weather/climate impact on farming, agricultural economics, and market yields.\n'
        '2. If the user asks about ANYTHING ELSE that is NOT related to agriculture (such as politics, movies, entertainment, sports, computer programming, games, non-agricultural history, celebrities, relationships, general trivia, mathematics, general science, greetings without agricultural context, etc.), you MUST POLITELY REFUSE using this exact refusal text:\n'
        '   $refusalText\n\n'
        '$languageRule\n\n'
        '4. CLARITY & POINT-BY-POINT STRUCTURE (MANDATORY):\n'
        '   - ALWAYS organize your explanation clearly POINT BY POINT using bold numbers (1., 2., 3.) or bullet points (•).\n'
        '   - Do NOT write dense or cluttered walls of paragraphs.\n'
        '   - Structure your advice with clean, bold section headers and emojis:\n'
        '$headersTemplate\n'
        '   - Under each section, provide specific, concise, numbered or bulleted actionable steps.\n'
        '   - Highlight all key measurements, dosages, application times, and crop names in bold.'
      ),
    );
  }

  Stream<String> streamChatAdvice({
    required String message,
    required String language,
    List<AgentChatTurn>? conversationHistory,
    String? cropType,
    String? gpsZone,
    double? latitude,
    double? longitude,
  }) async* {
    final contextParts = <String>[];
    if (cropType != null && cropType.isNotEmpty) {
      if (language == 'si') {
        contextParts.add('අදාළ බෝගය: $cropType');
      } else if (language == 'ta') {
        contextParts.add('பயிர்: $cropType');
      } else {
        contextParts.add('Target Crop: $cropType');
      }
    }
    if (latitude != null && longitude != null) {
      if (language == 'si') {
        contextParts.add('ස්ථානය: $latitude, $longitude');
      } else if (language == 'ta') {
        contextParts.add('அமைவிடம்: $latitude, $longitude');
      } else {
        contextParts.add('Location: $latitude, $longitude');
      }
    }
    if (gpsZone != null && gpsZone.isNotEmpty) {
      if (language == 'si') {
        contextParts.add('කලාපය: $gpsZone');
      } else if (language == 'ta') {
        contextParts.add('வலயம்: $gpsZone');
      } else {
        contextParts.add('Zone: $gpsZone');
      }
    }

    String promptWithContext = message;
    if (contextParts.isNotEmpty) {
      if (language == 'si') {
        promptWithContext = '[ගොවියාගේ තොරතුරු: ${contextParts.join(', ')}]\n\nප්‍රශ්නය: $message';
      } else if (language == 'ta') {
        promptWithContext = '[விவசாயி விவரம்: ${contextParts.join(', ')}]\n\nகேள்வி: $message';
      } else {
        promptWithContext = '[Farmer Context: ${contextParts.join(', ')}]\n\nQuestion: $message';
      }
    }

    // Build multi-turn context contents
    final contents = <Content>[];
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      final validTurns = conversationHistory
          .where((t) => t.text.trim().isNotEmpty)
          .toList();
      
      // Include up to recent 10 messages for context continuity
      final turnsToInclude = validTurns.length > 10
          ? validTurns.sublist(validTurns.length - 10)
          : validTurns;

      for (final turn in turnsToInclude) {
        if (turn.isUser) {
          contents.add(Content.text(turn.text));
        } else {
          contents.add(Content.model([TextPart(turn.text)]));
        }
      }
    }

    // Append current prompt
    contents.add(Content.text(promptWithContext));

    // Try primary model: gemini-3.1-flash-lite
    bool streamStarted = false;
    try {
      final primaryModel = _getModel(language, modelName: 'gemini-3.1-flash-lite');
      final responseStream = primaryModel.generateContentStream(contents);

      await for (final chunk in responseStream) {
        if (chunk.text != null && chunk.text!.isNotEmpty) {
          streamStarted = true;
          yield chunk.text!;
        }
      }
    } catch (e) {
      // If primary model fails before streaming, fallback to gemini-3-flash-preview
      if (!streamStarted) {
        try {
          final fallbackModel = _getModel(language, modelName: 'gemini-3-flash-preview');
          final fallbackStream = fallbackModel.generateContentStream(contents);
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
