import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';
import '../models/queue_status.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiService {
  // Use 10.0.2.2 for Android emulator to access localhost,
  // or your machine's IP address if using a physical device.
  // For Chrome web (flutter run --device chrome), localhost:8000 is correct.
  static String get baseUrl {
    if (kIsWeb) {
      // Running on Chrome
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      // Android emulator: 10.0.2.2 maps to host machine's localhost
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost directly
      return 'http://localhost:8000/api';
    } else {
      return 'http://localhost:8000/api';
    }
  }

  /// Fetch all active services.
  Future<List<Service>> fetchServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data
              .map((serviceJson) => Service.fromJson(serviceJson))
              .toList();
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

  /// Fetch already-booked time slots for a given date.
  Future<List<String>> fetchBookedTimes(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/booked-times?date=$date'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return List<String>.from(jsonResponse['data']);
        }
        return [];
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load booked times: $e');
    }
  }

  /// Fetch queue status for a given date.
  Future<QueueStatus> fetchQueueStatus(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/queue-status?date=$date'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return QueueStatus.fromJson(jsonResponse['data']);
        }
        return QueueStatus(appointments: []);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to load queue status: $e');
    }
  }

  /// Book an appointment. Supports optional valid_id image upload.
  Future<Map<String, dynamic>> bookAppointment({
    required String firstName,
    required String lastName,
    String? middleName,
    required int serviceId,
    required String schedule,
    required String scheduleTime,
    required String dateOfBirth,
    required String gender,
    String? phone,
    String? email,
    String? address,
    List<int>? validIdBytes,
    String? validIdFilename,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/appointments'),
      );

      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      if (middleName != null && middleName.isNotEmpty) {
        request.fields['middle_name'] = middleName;
      }
      request.fields['service_id'] = serviceId.toString();
      request.fields['schedule'] = schedule;
      request.fields['schedule_time'] = scheduleTime;
      request.fields['date_of_birth'] = dateOfBirth;
      request.fields['gender'] = gender;
      if (phone != null && phone.isNotEmpty) request.fields['phone'] = phone;
      if (email != null && email.isNotEmpty) request.fields['email'] = email;
      if (address != null && address.isNotEmpty) {
        request.fields['address'] = address;
      }

      if (validIdBytes != null && validIdFilename != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'valid_id',
            validIdBytes,
            filename: validIdFilename,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 201 && jsonResponse['success'] == true) {
        return jsonResponse['data'];
      } else {
        final message = jsonResponse['message'] ?? 'Booking failed';
        final errors = jsonResponse['errors'];
        String errorDetail = message;
        if (errors is Map) {
          errorDetail = errors.values
              .expand((v) => v is List ? v : [v])
              .join('\n');
        }
        throw Exception(errorDetail);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to book appointment: $e');
    }
  }
}
