import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  String? _role;
  String? get role => _role;

  // ================= LOGIN =================
  Future<Map?> login(String email, String password) async {
    try {
      // 🔴 IMPORTANT: send EMAIL, not phone
      final response = await _api.post("/api/v1/auth/login", {
        "email": email,
        "password": password,
      });

      // 🔍 Debug (you can remove later)
      debugPrint("AUTH PROVIDER LOGIN RESPONSE: $response");

      if (response == null) {
        throw Exception("No response from server");
      }

      if (response["success"] == true) {
        final data = response["data"];

        // 🔐 OTP ONLY FOR ADMIN (Backend decides)
        if (data["requiresOtp"] == true) {
          return data; // Admin OTP flow
        }

        // ✅ STUDENT / FACULTY LOGIN (NO OTP)
        print("LOGIN STARTED");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);

        _role = data["role"];
        notifyListeners();

        return data;
      }

      throw Exception(response["message"] ?? "Login failed");
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      rethrow;
    }
  }

  // ================= VERIFY OTP (ADMIN ONLY) =================
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
      debugPrint("OTP ERROR: $e");
      rethrow;
    }
  }

<<<<<<< HEAD
=======
  // ================= RESEND OTP =================
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
  Future<void> resendOtp(int userId) async {
    try {
      final response = await _api.post("/api/v1/auth/resend-otp", {
        "userId": userId,
      });

      if (response["success"] != true) {
        throw Exception(response["message"] ?? "Failed to resend OTP");
      }
    } catch (e) {
<<<<<<< HEAD
=======
      debugPrint("RESEND OTP ERROR: $e");
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
      rethrow;
    }
  }

<<<<<<< HEAD
=======
  // ================= LOGOUT =================
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    _role = null;
    notifyListeners();
  }
}
