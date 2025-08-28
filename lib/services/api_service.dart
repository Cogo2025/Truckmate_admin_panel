import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_model.dart';
import '../models/user_models.dart';

class ApiService {
  static const String baseUrl = 'https://truckmate-servermvp.onrender.com';

  // Token Management
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

  // Helper method for auth headers (alternative name for consistency)
  Future<Map<String, String>> _getAuthHeaders() async {
    return await _getHeaders();
  }

  // Error handling helper
  Exception _handleError(int statusCode, String body, String operation) {
    switch (statusCode) {
      case 400:
        return Exception('Bad Request: $body');
      case 401:
        return Exception('Unauthorized - please login again');
      case 403:
        return Exception('Forbidden - insufficient permissions');
      case 404:
        return Exception('Not Found: $body');
      case 500:
        return Exception('Server Error: $body');
      default:
        return Exception('$operation failed: $statusCode - $body');
    }
  }

  // ========================================
  // AUTHENTICATION ENDPOINTS
  // ========================================

  Future<Map<String, dynamic>> initialLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/initial-login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final result = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (result['token'] != null) {
          await saveToken(result['token']);
        }
        return result;
      } else {
        throw _handleError(response.statusCode, response.body, 'Initial login');
      }
    } catch (e) {
      throw Exception('Initial login failed: $e');
    }
  }

  Future<Map<String, dynamic>> adminLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final result = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (result['token'] != null) {
          await saveToken(result['token']);
        }
        if (result['admin'] != null) {
          result['admin']['isFirstLogin'] = result['admin']['isFirstLogin'] ?? false;
        }
        return result;
      } else {
        throw _handleError(response.statusCode, response.body, 'Admin login');
      }
    } catch (e) {
      throw Exception('Admin login failed: $e');
    }
  }

  Future<Map<String, dynamic>> changePassword(String? currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/change-password'),
        headers: await _getHeaders(),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final result = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return result;
      } else {
        throw _handleError(response.statusCode, response.body, 'Change password');
      }
    } catch (e) {
      throw Exception('Change password failed: $e');
    }
  }

  Future<Map<String, dynamic>> createNewAdmin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/create-admin'),
        headers: await _getHeaders(),
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final result = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return result;
      } else {
        throw _handleError(response.statusCode, response.body, 'Create admin');
      }
    } catch (e) {
      throw Exception('Create admin failed: $e');
    }
  }

  Future<void> logout() async {
    await removeToken();
  }

  // ========================================
  // DASHBOARD & DATA ENDPOINTS
  // ========================================

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/dashboard'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleError(response.statusCode, response.body, 'Get dashboard data');
      }
    } catch (e) {
      throw Exception('Get dashboard data failed: $e');
    }
  }

  Future<List<Driver>> getAllDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/drivers'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['drivers'] as List)
              .map((json) => Driver.fromJson(json))
              .toList();
        } else {
          throw Exception(data['error'] ?? 'Failed to fetch drivers');
        }
      } else {
        throw _handleError(response.statusCode, response.body, 'Get drivers');
      }
    } catch (e) {
      throw Exception('Get drivers failed: $e');
    }
  }

  Future<List<Owner>> getAllOwners() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/owners'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['owners'] as List)
              .map((json) => Owner.fromJson(json))
              .toList();
        } else {
          throw Exception(data['error'] ?? 'Failed to fetch owners');
        }
      } else {
        throw _handleError(response.statusCode, response.body, 'Get owners');
      }
    } catch (e) {
      throw Exception('Get owners failed: $e');
    }
  }

  // ========================================
  // VERIFICATION ENDPOINTS
  // ========================================

  Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/verification/pending'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw _handleError(response.statusCode, response.body, 'Get pending verifications');
      }
    } catch (e) {
      throw Exception('Get pending verifications failed: $e');
    }
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
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw _handleError(response.statusCode, response.body, 'Get all verifications');
      }
    } catch (e) {
      print('Error in getAllVerifications: $e'); // Debug log
      throw Exception('Get all verifications failed: $e');
    }
  }

  Future<Map<String, dynamic>> processVerification(String requestId, String action, String? notes) async {
    try {
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
      } else {
        throw _handleError(response.statusCode, response.body, 'Process verification');
      }
    } catch (e) {
      throw Exception('Process verification failed: $e');
    }
  }

  Future<Map<String, dynamic>> getVerificationStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/verification/stats'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleError(response.statusCode, response.body, 'Get verification stats');
      }
    } catch (e) {
      throw Exception('Get verification stats failed: $e');
    }
  }

  // Additional verification endpoints
  Future<Map<String, dynamic>> createVerificationRequest() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/verification/request'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw _handleError(response.statusCode, response.body, 'Create verification request');
      }
    } catch (e) {
      throw Exception('Create verification request failed: $e');
    }
  }

  Future<Map<String, dynamic>> getDriverVerificationStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/verification/status'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleError(response.statusCode, response.body, 'Get driver verification status');
      }
    } catch (e) {
      throw Exception('Get driver verification status failed: $e');
    }
  }

  Future<Map<String, dynamic>> checkDriverAccess() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/verification/check-access'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleError(response.statusCode, response.body, 'Check driver access');
      }
    } catch (e) {
      throw Exception('Check driver access failed: $e');
    }
  }

  Future<Map<String, dynamic>> resubmitVerification() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/verification/resubmit'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw _handleError(response.statusCode, response.body, 'Resubmit verification');
      }
    } catch (e) {
      throw Exception('Resubmit verification failed: $e');
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Test connection to server
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/dashboard'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      return false;
    }
  }

  // Generic GET request method
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleError(response.statusCode, response.body, 'GET $endpoint');
      }
    } catch (e) {
      throw Exception('GET $endpoint failed: $e');
    }
  }

  // Generic POST request method
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw _handleError(response.statusCode, response.body, 'POST $endpoint');
      }
    } catch (e) {
      throw Exception('POST $endpoint failed: $e');
    }
  }

  // Generic PUT request method
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleError(response.statusCode, response.body, 'PUT $endpoint');
      }
    } catch (e) {
      throw Exception('PUT $endpoint failed: $e');
    }
  }

  // Generic DELETE request method
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty ? json.decode(response.body) : {'success': true};
      } else {
        throw _handleError(response.statusCode, response.body, 'DELETE $endpoint');
      }
    } catch (e) {
      throw Exception('DELETE $endpoint failed: $e');
    }
  }
}
