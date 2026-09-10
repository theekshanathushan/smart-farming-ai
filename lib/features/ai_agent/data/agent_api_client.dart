import 'dart:convert';
import 'package:http/http.dart' as http;

class AgentApiClient {
  final String baseUrl = 'http://10.0.2.2:8000'; // Computer's IP for physical device testing

  Stream<String> streamChatAdvice({
    required String message,
    required String language,
    String? cropType,
    String? gpsZone,
    double? latitude,
    double? longitude,
  }) async* {
    final client = http.Client();
    final request = http.Request(
      'POST', 
      Uri.parse('$baseUrl/api/v1/chat/stream'),
    );
    
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';
    request.body = jsonEncode({
      'message': message,
      'language': language,
      'crop_type': cropType,
      'gps_zone': gpsZone,
      'latitude': latitude,
      'longitude': longitude,
    });

    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to connect to AI streaming endpoint');
      }

      // Listen to the byte stream, decode to String, and process line by line
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          
          if (line.startsWith('data: ')) {
            final dataString = line.substring(6).trim();
            
            // Standard convention to close the stream
            if (dataString == '[DONE]') return; 
            
            try {
              final jsonData = jsonDecode(dataString);
              // Yield the parsed text token to the UI
              if (jsonData.containsKey('chunk')) {
                yield jsonData['chunk'];
              }
            } catch (e) {
              // Ignore malformed JSON chunks
              continue;
            }
          }
        }
      }
    } finally {
      client.close(); // Prevent memory leaks by closing the connection
    }
  }
}
