import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  String? _role;
  String? get role => _role;

  Future<bool> login(String email, String password) async {
    try {
      // ✅ FIXED ENDPOINT (THIS WAS THE BUG)
      final response = await _api.post(
        "/api/v1/auth/login",
        {
          "email": email,
          "password": password,
        },
      );

      if (response["success"] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", response["data"]["token"]);

        _role = response["data"]["role"];
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    _role = null;
    notifyListeners();
  }
}
