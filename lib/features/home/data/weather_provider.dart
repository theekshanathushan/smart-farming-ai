import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/location_service.dart';

final weatherProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final position = await LocationService.getCurrentLocation();
  if (position == null) {
    throw Exception('Location permission denied or unavailable');
  }

  // Use localhost for emulator, or appropriate IP for physical device
  final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';
  
  final url = Uri.parse('$baseUrl/api/v1/weather?lat=${position.latitude}&lon=${position.longitude}');
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load weather data');
  }
});
