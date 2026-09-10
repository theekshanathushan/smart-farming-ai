import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final marketPricesProvider = FutureProvider<List<dynamic>>((ref) async {
  final baseUrl = 'http://10.16.135.91:8000';
  
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/market-prices')).timeout(
      const Duration(seconds: 3),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] as List<dynamic>;
    }
  } catch (e) {
    // Fallback if backend is offline
  }

  // Realistic mock data for Sri Lankan market (Fallback for offline)
  await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
  return [
    {'crop': 'Samba Rice', 'price': 240.0, 'unit': 'kg', 'trend': 'stable', 'market': 'Dambulla'},
    {'crop': 'Carrot', 'price': 380.0, 'unit': 'kg', 'trend': 'up', 'market': 'Nuwara Eliya'},
    {'crop': 'Tomato', 'price': 150.0, 'unit': 'kg', 'trend': 'down', 'market': 'Dambulla'},
    {'crop': 'Big Onion', 'price': 310.0, 'unit': 'kg', 'trend': 'up', 'market': 'Pettah'},
    {'crop': 'Potato', 'price': 220.0, 'unit': 'kg', 'trend': 'stable', 'market': 'Nuwara Eliya'},
    {'crop': 'Cabbage', 'price': 160.0, 'unit': 'kg', 'trend': 'down', 'market': 'Keppetipola'},
  ];
});
