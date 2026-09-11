import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/location_service.dart';

String _getWeatherDescription(int code) {
  if (code <= 1) return 'Clear Sky';
  if (code <= 3) return 'Partly Cloudy';
  if (code < 50) return 'Foggy';
  if (code < 60) return 'Drizzle';
  if (code < 70) return 'Rainy';
  if (code < 80) return 'Snowy';
  return 'Stormy';
}

final weatherProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  
  double lat = 7.8592; // Dambulla fallback
  double lon = 80.6517;

  try {
    final position = await locationService.getCurrentLocation();
    if (position != null) {
      lat = position.latitude;
      lon = position.longitude;
    }
  } catch (e) {
    // Ignore and use fallback
  }

  final url = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
  final response = await http.get(url).timeout(
    const Duration(seconds: 10),
    onTimeout: () => throw Exception('Connection timeout. Unable to fetch weather data.'),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final current = data['current_weather'];
    return {
      'temperature': current['temperature'].round(),
      'description': _getWeatherDescription(current['weathercode']),
    };
  } else {
    throw Exception('Failed to load weather data');
  }
});
