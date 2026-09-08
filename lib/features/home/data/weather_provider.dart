import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/location_service.dart';

final weatherProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final position = await locationService.getCurrentLocation();
  if (position == null) {
    throw Exception('Location permission denied or unavailable');
  }

  // Use computer's IP address for physical device testing
  final baseUrl = 'http://172.19.167.230:8000';
  
  final url = Uri.parse('$baseUrl/api/v1/weather?lat=${position.latitude}&lon=${position.longitude}');
  final response = await http.get(url).timeout(
    const Duration(seconds: 5),
    onTimeout: () => throw Exception('Connection timeout. Ensure backend is running and reachable.'),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load weather data');
  }
});
