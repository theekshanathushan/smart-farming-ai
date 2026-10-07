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
  // Watch real-time location resolution
  final locationAsync = ref.watch(userLocationProvider);
  final userLocation = locationAsync.value ?? UserLocation.fallback();

  final lat = userLocation.latitude;
  final lon = userLocation.longitude;

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
      'city': userLocation.city,
      'district': userLocation.district,
      'location': userLocation.displayName,
      'latitude': lat,
      'longitude': lon,
      'isAccurate': userLocation.isAccurate,
    };
  } else {
    throw Exception('Failed to load weather data');
  }
});
