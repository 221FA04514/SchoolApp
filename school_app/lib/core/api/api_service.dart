import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class ApiService {

  // ================= TOKEN =================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  // ================= POST =================
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}$endpoint"),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data["message"] ?? "API error");
      }
    } catch (e) {
      print("POST API ERROR [$endpoint]: $e");
      throw Exception("Network error");
    }
  }

  // ================= GET =================
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}$endpoint"),
        headers: await _headers(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data["message"] ?? "API error");
      }
    } catch (e) {
      print("GET API ERROR [$endpoint]: $e");
      throw Exception("Network error");
    }
  }
}
