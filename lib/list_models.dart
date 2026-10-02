import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:io';

void main() async {
  final envContent = await File('.env').readAsString();
  final apiKey = envContent.split('\n').firstWhere((l) => l.startsWith('GEMINI_API_KEY=')).replaceFirst('GEMINI_API_KEY=', '').trim();
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  
  try {
    print('Fetching models...');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = data['models'] as List;
      print('Available models:');
      for (var model in models) {
        print("- ${model['name']}");
      }
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Exception: \$e');
  }
}
