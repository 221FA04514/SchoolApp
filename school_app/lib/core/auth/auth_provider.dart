import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  String? _role;
  String? get role => _role;

  Future<Map?> login(String email, String password) async {
    try {
      final response = await _api.post("/api/v1/auth/login", {
        "email": email,
        "password": password,
      });

      if (response["success"] == true) {
        if (response["data"]["requiresOtp"] == true) {
          return response["data"]; // Return {requiresOtp, userId, phone}
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", response["data"]["token"]);

        _role = response["data"]["role"];
        notifyListeners();
        return response["data"];
      }

      throw Exception(response["message"] ?? "Login failed");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOtp(int userId, String code) async {
    try {
      final response = await _api.post("/api/v1/auth/verify-otp", {
        "userId": userId,
        "code": code,
      });

      if (response["success"] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", response["data"]["token"]);

        _role = response["data"]["role"];
        notifyListeners();
      } else {
        throw Exception(response["message"] ?? "OTP verification failed");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendOtp(int userId) async {
    try {
      final response = await _api.post("/api/v1/auth/resend-otp", {
        "userId": userId,
      });

      if (response["success"] != true) {
        throw Exception(response["message"] ?? "Failed to resend OTP");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    _role = null;
    notifyListeners();
  }
}
