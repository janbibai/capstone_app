import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to access localhost,
  // or your machine's IP address if using a physical device.
  // For Chrome web (flutter run --device chrome), localhost:8000 is correct.
  static const String baseUrl = 'http://localhost:8000/api';

  Future<List<Service>> fetchServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((serviceJson) => Service.fromJson(serviceJson)).toList();
        } else {
          throw Exception('Failed to parse services from response data');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load services: $e');
    }
  }
}
