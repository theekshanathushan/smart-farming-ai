import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/location_service.dart';

class WeatherConditionMeta {
  final String condition;
  final String emoji;
  final String descriptionEn;
  final String descriptionSi;
  final String descriptionTa;

  const WeatherConditionMeta({
    required this.condition,
    required this.emoji,
    required this.descriptionEn,
    required this.descriptionSi,
    required this.descriptionTa,
  });
}

WeatherConditionMeta getWeatherMeta(int code, {bool isDay = true}) {
  if (code == 0) {
    return WeatherConditionMeta(
      condition: 'sunny',
      emoji: isDay ? '☀️' : '🌙',
      descriptionEn: isDay ? 'Sunny' : 'Clear Night',
      descriptionSi: isDay ? 'හිරු රැස් සහිතයි' : 'පැහැපත් රාත්‍රිය',
      descriptionTa: isDay ? 'வெயில்' : 'தெளிவான இரவு',
    );
  } else if (code == 1) {
    return WeatherConditionMeta(
      condition: 'mostly_sunny',
      emoji: isDay ? '🌤️' : '🌤️',
      descriptionEn: 'Mainly Clear',
      descriptionSi: 'ප්‍රධාන වශයෙන් පැහැපත්',
      descriptionTa: 'பெரும்பாலும் தெளிவானது',
    );
  } else if (code == 2) {
    return const WeatherConditionMeta(
      condition: 'partly_cloudy',
      emoji: '⛅',
      descriptionEn: 'Partly Cloudy',
      descriptionSi: 'මද වශයෙන් වලාකුළු',
      descriptionTa: 'பகுதி மேகமூட்டம்',
    );
  } else if (code == 3) {
    return const WeatherConditionMeta(
      condition: 'cloudy',
      emoji: '☁️',
      descriptionEn: 'Cloudy',
      descriptionSi: 'වලාකුළු සහිතයි',
      descriptionTa: 'மேகமூட்டம்',
    );
  } else if (code >= 45 && code <= 48) {
    return const WeatherConditionMeta(
      condition: 'foggy',
      emoji: '🌫️',
      descriptionEn: 'Foggy',
      descriptionSi: 'මීදුම් සහිතයි',
      descriptionTa: 'பனிமூட்டம்',
    );
  } else if (code >= 51 && code <= 57) {
    return const WeatherConditionMeta(
      condition: 'drizzle',
      emoji: '🌦️',
      descriptionEn: 'Drizzle',
      descriptionSi: 'පොද වැසි',
      descriptionTa: 'தூறල් மழை',
    );
  } else if ((code >= 61 && code <= 67) || (code >= 80 && code <= 84)) {
    return const WeatherConditionMeta(
      condition: 'rainy',
      emoji: '🌧️',
      descriptionEn: 'Rainy',
      descriptionSi: 'වැසි සහිතයි',
      descriptionTa: 'மழை',
    );
  } else if ((code >= 71 && code <= 77) || (code >= 85 && code <= 89)) {
    return const WeatherConditionMeta(
      condition: 'snowy',
      emoji: '❄️',
      descriptionEn: 'Snowy',
      descriptionSi: 'හිම සහිතයි',
      descriptionTa: 'பனிப்பொழிவு',
    );
  } else if (code >= 90) {
    return const WeatherConditionMeta(
      condition: 'stormy',
      emoji: '⛈️',
      descriptionEn: 'Stormy',
      descriptionSi: 'ගිගුරුම් සහිත වැසි',
      descriptionTa: 'இடி மின்னலுடன் மழை',
    );
  }

  return const WeatherConditionMeta(
    condition: 'partly_cloudy',
    emoji: '⛅',
    descriptionEn: 'Partly Cloudy',
    descriptionSi: 'මද වශයෙන් වලාකුළු',
    descriptionTa: 'பகுதி மேகமூட்டம்',
  );
}

final weatherProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Watch real-time location resolution
  final locationAsync = ref.watch(userLocationProvider);
  final userLocation = locationAsync.value ?? UserLocation.fallback();

  final lat = userLocation.latitude;
  final lon = userLocation.longitude;

  try {
    final url = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
    final response = await http.get(url).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Connection timeout. Unable to fetch weather data.'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final current = data['current_weather'];
      final code = (current['weathercode'] as num?)?.toInt() ?? 0;
      final isDay = (current['is_day'] as num?)?.toInt() != 0;
      final meta = getWeatherMeta(code, isDay: isDay);

      return {
        'temperature': current['temperature'].round(),
        'weathercode': code,
        'condition': meta.condition,
        'emoji': meta.emoji,
        'description': meta.descriptionEn,
        'description_en': meta.descriptionEn,
        'description_si': meta.descriptionSi,
        'description_ta': meta.descriptionTa,
        'city': userLocation.city,
        'district': userLocation.district,
        'location': userLocation.displayName,
        'latitude': lat,
        'longitude': lon,
        'isAccurate': userLocation.isAccurate,
        'isOffline': false,
      };
    } else {
      throw Exception('Failed to load weather data');
    }
  } catch (_) {
    // Graceful offline fallback: tropical default baseline for Sri Lanka
    final fallbackMeta = getWeatherMeta(2);
    return {
      'temperature': 28,
      'weathercode': 2,
      'condition': fallbackMeta.condition,
      'emoji': fallbackMeta.emoji,
      'description': fallbackMeta.descriptionEn,
      'description_en': fallbackMeta.descriptionEn,
      'description_si': fallbackMeta.descriptionSi,
      'description_ta': fallbackMeta.descriptionTa,
      'city': userLocation.city,
      'district': userLocation.district,
      'location': userLocation.displayName,
      'latitude': lat,
      'longitude': lon,
      'isAccurate': userLocation.isAccurate,
      'isOffline': true,
    };
  }
});
