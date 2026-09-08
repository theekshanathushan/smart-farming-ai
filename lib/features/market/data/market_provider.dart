import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final marketPricesProvider = FutureProvider<List<dynamic>>((ref) async {
  // Use localhost for emulator, or appropriate IP for physical device
  final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';
  
  final response = await http.get(Uri.parse('$baseUrl/api/v1/market-prices'));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] as List<dynamic>;
  } else {
    throw Exception('Failed to load market prices');
  }
});
