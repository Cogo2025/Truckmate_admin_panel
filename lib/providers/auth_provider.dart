import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/admin_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Admin? _admin;
  bool _isLoading = false;
  String? _error;
  
  Admin? get admin => _admin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _admin != null;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // First try admin login
      var result = await _apiService.adminLogin(username, password);
      
      if (result['success'] == true) {  // Explicit boolean check
        await _apiService.saveToken(result['token']);
        _admin = Admin.fromJson(result['admin'] ?? {}); // Handle null admin
        _setLoading(false);
        return true;
      } else {
        // If admin login fails, try initial login
        result = await _apiService.initialLogin(username, password);
        
        if (result['success'] == true) {  // Explicit boolean check
          await _apiService.saveToken(result['token']);
          _admin = Admin.fromJson(result['admin'] ?? {}); // Handle null admin
          _setLoading(false);
          return true;
        } else {
          _setError(result['error']?.toString() ?? 'Login failed');
          _setLoading(false);
          return false;
        }
      }
    } catch (e) {
      _setError('Connection error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> changePassword(String? currentPassword, String newPassword) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _apiService.changePassword(currentPassword, newPassword);
      
      if (result['success']) {
        if (_admin != null) {
          _admin = Admin(
            id: _admin!.id,
            username: _admin!.username,
            isFirstLogin: false,
            lastLogin: _admin!.lastLogin,
          );
        }
        _setLoading(false);
        return true;
      } else {
        _setError(result['error']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Connection error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> createNewAdmin(String username, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _apiService.createNewAdmin(username, password);
      
      if (result['success']) {
        _setLoading(false);
        return true;
      } else {
        _setError(result['error']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Connection error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // FIXED: Enhanced logout method
  Future<void> logout(BuildContext? context) async {
    try {
      // Remove token from storage
      await _apiService.removeToken();
      
      // Clear admin data
      _admin = null;
      _error = null;
      
      // Notify listeners
      notifyListeners();
      
      // Navigate to login screen if context is provided
      if (context != null && context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      print('Logout error: $e');
      // Even if there's an error, clear the local state
      _admin = null;
      _error = null;
      notifyListeners();
      
      if (context != null && context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }
  
  // ADDED: Method to clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Check if user is still authenticated on app start
  Future<void> checkAuth() async {
    final token = await _apiService.getToken();
    if (token != null) {
      // You might want to validate the token with the server here
      // For now, we'll just assume it's valid if it exists
    }
  }
}