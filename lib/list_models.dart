import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = 'AQ.Ab8RN6IzdCy8-_-1YdVmcfp95slPE1Jk1BgafNY9eV_y0ChvrA';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=\$apiKey');
  
  try {
    print('Fetching models...');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = data['models'] as List;
      print('Available models:');
      for (var model in models) {
        print("- \${model['name']}");
      }
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Exception: \$e');
  }
}
