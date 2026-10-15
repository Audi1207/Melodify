import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// AuthProvider mengelola state autentikasi user
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  // Load data user dari SharedPreferences saat app pertama dibuka
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');
    final userName = prefs.getString('user_name');
    final userEmail = prefs.getString('user_email');

    if (token != null && userId != null) {
      _user = User(
        id: userId,
        name: userName ?? '',
        email: userEmail ?? '',
      );
      notifyListeners();
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.login(email, password);

    if (result['success']) {
      _user = User.fromJson(result['user']);
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Register
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.register(name, email, password);

    if (result['success']) {
      _user = User.fromJson(result['user']);
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}
