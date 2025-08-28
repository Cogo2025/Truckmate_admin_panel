import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_model.dart';
import '../models/user_models.dart';

class ApiService {
  static const String baseUrl = 'https://truckmate-servermvp.onrender.com';
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_token');
  }
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', token);
  }
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
  }
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Existing auth endpoints...
  Future<Map<String, dynamic>> initialLogin(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/initial-login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> adminLogin(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    final result = json.decode(response.body);
    if (result['admin'] != null) {
      result['admin']['isFirstLogin'] = result['admin']['isFirstLogin'] ?? false;
    }
    return result;
  }

  Future<Map<String, dynamic>> changePassword(String? currentPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/change-password'),
      headers: await _getHeaders(),
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createNewAdmin(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/create-admin'),
      headers: await _getHeaders(),
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    return json.decode(response.body);
  }

  // Existing data endpoints...
  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/dashboard'),
      headers: await _getHeaders(),
    );
    return json.decode(response.body);
  }

  Future<List<Driver>> getAllDrivers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/drivers'),
      headers: await _getHeaders(),
    );
    final data = json.decode(response.body);
    if (data['success']) {
      return (data['drivers'] as List)
          .map((json) => Driver.fromJson(json))
          .toList();
    }
    throw Exception('Failed to fetch drivers');
  }

  Future<List<Owner>> getAllOwners() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/owners'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch owners: ${response.statusCode}');
    }
    final data = json.decode(response.body);
    if (data['success'] == true) {
      return (data['owners'] as List)
          .map((json) => Owner.fromJson(json))
          .toList();
    }
    throw Exception(data['error'] ?? 'Failed to fetch owners');
  }

  // ✅ NEW: Verification API endpoints
  Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/verification/pending'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to fetch pending verifications');
  }

  Future<List<Map<String, dynamic>>> getAllVerifications() async {
  try {
    final token = await getToken();
    if (token == null) throw Exception('No authentication token');
    
    print('Making request to: $baseUrl/api/verification/all'); // Debug log
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/verification/all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    print('Response status: ${response.statusCode}'); // Debug log
    print('Response body: ${response.body}'); // Debug log
    
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - please login again');
    } else {
      throw Exception('Server error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error in getAllVerifications: $e'); // Debug log
    throw Exception('Error fetching verification history: $e');
  }
}


  Future<Map<String, dynamic>> processVerification(String requestId, String action, String? notes) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/verification/$requestId/process'),
      headers: await _getHeaders(),
      body: json.encode({
        'action': action,
        'notes': notes,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to process verification');
  }

  Future<Map<String, dynamic>> getVerificationStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/verification/stats'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch verification stats');
  }
}
