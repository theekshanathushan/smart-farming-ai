import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final marketPricesProvider = FutureProvider<List<dynamic>>((ref) async {
  // Use computer's IP address for physical device testing
  final baseUrl = 'http://172.19.167.230:8000';
  
  final response = await http.get(Uri.parse('$baseUrl/api/v1/market-prices')).timeout(
    const Duration(seconds: 5),
    onTimeout: () => throw Exception('Connection timeout. Ensure backend is reachable.'),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] as List<dynamic>;
  } else {
    throw Exception('Failed to load market prices');
  }
});
