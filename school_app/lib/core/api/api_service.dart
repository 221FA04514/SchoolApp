import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart' as dio_lib;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;
  ApiException(this.message, this.statusCode, this.data);
  @override
  String toString() => message;
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  // ================= TOKEN =================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // ================= GLOBAL DATA CAPITALIZATION =================
  dynamic _capitalizeData(dynamic data) {
    if (data is String) {
      if (data.isEmpty) return data;
      // Skip strings that look like URLs, emails, dates, times, file paths
      if (data.startsWith('http') || data.contains('@') || data.contains('://') || data.contains(RegExp(r'\d{4}-\d{2}-\d{2}'))) {
        return data;
      }
      // Skip known lowercase constants/enums
      final lower = data.toLowerCase();
      const skipValues = {'student', 'teacher', 'admin', 'pdf', 'mp4', 'mov', 'file', 'paid', 'pending', 'present', 'absent', 'late', 'half_day', 'holiday', 'seen', 'delivered', 'dismissed'};
      if (skipValues.contains(lower)) return data;

      // Capitalize first letter
      return data[0].toUpperCase() + data.substring(1);
    } else if (data is List) {
      return data.map((e) => _capitalizeData(e)).toList();
    } else if (data is Map<String, dynamic>) {
      final Map<String, dynamic> capitalizedMap = {};
      const skipKeys = {'id', '_id', 'file_url', 'image_url', 'attachment_url', 'email', 'password', 'token', 'status', 'type', 'role', 'created_at', 'updated_at', 'deleted_at', 'scheduled_at', 'deadline', 'date', 'time', 'receipt_status'};
      data.forEach((key, value) {
        if (skipKeys.contains(key.toLowerCase()) || key.toLowerCase().endsWith('id')) {
          capitalizedMap[key] = value;
        } else {
          capitalizedMap[key] = _capitalizeData(value);
        }
      });
      return capitalizedMap;
    }
    return data;
  }

  // ================= POST =================
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse("${AppConstants.baseUrl}$endpoint"),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _capitalizeData(data);
      } else {
        throw ApiException(
          data["message"] ?? "API error",
          response.statusCode,
          data,
        );
      }
    } on TimeoutException {
      throw Exception("Server timeout. Please try again.");
    } catch (e) {
      print("POST API ERROR [$endpoint]: $e");
      rethrow;
    }
  }

  // ================= GET =================
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse("${AppConstants.baseUrl}$endpoint"),
            headers: await _headers(),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _capitalizeData(data);
      } else {
        throw ApiException(
          data["message"] ?? "API error",
          response.statusCode,
          data,
        );
      }
    } on TimeoutException {
      throw Exception("Server timeout. Please try again.");
    } catch (e) {
      print("GET API ERROR [$endpoint]: $e");
      rethrow;
    }
  }

  // ================= DELETE =================
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse("${AppConstants.baseUrl}$endpoint"),
            headers: await _headers(),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _capitalizeData(data);
      } else {
        throw ApiException(
          data["message"] ?? "API error",
          response.statusCode,
          data,
        );
      }
    } on TimeoutException {
      throw Exception("Server timeout. Please try again.");
    } catch (e) {
      print("DELETE API ERROR [$endpoint]: $e");
      rethrow;
    }
  }

  // ================= PUT =================
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse("${AppConstants.baseUrl}$endpoint"),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _capitalizeData(data);
      } else {
        throw ApiException(
          data["message"] ?? "API error",
          response.statusCode,
          data,
        );
      }
    } on TimeoutException {
      throw Exception("Server timeout. Please try again.");
    } catch (e) {
      print("PUT API ERROR [$endpoint]: $e");
      rethrow;
    }
  }

  // ================= PATCH =================
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .patch(
            Uri.parse("${AppConstants.baseUrl}$endpoint"),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _capitalizeData(data);
      } else {
        throw ApiException(
          data["message"] ?? "API error",
          response.statusCode,
          data,
        );
      }
    } on TimeoutException {
      throw Exception("Server timeout. Please try again.");
    } catch (e) {
      print("PATCH API ERROR [$endpoint]: $e");
      rethrow;
    }
  }

  // ================= MULTIPART (Upload) =================
  Future<dynamic> postMultipart(
    String endpoint,
    dio_lib.FormData formData,
  ) async {
    try {
      final token = await _getToken();
      final dio = dio_lib.Dio();

      final fullUrl = "${AppConstants.baseUrl}$endpoint";
      print("[API] POST MULTIPART: $fullUrl");
      print(
        "[API] Headers: {Authorization: Bearer ${token?.substring(0, 10)}...}",
      );
      print(
        "[API] Fields: ${formData.fields.map((f) => "${f.key}: ${f.value}")}",
      );

      final response = await dio.post(
        fullUrl,
        data: formData,
        options: dio_lib.Options(
          sendTimeout: const Duration(seconds: 300),
          receiveTimeout: const Duration(seconds: 300),
          headers: {
            if (token != null && token.isNotEmpty)
              "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return _capitalizeData(response.data);
      } else {
        throw ApiException(
          response.data["message"] ?? "Upload error",
          response.statusCode!,
          response.data,
        );
      }
    } catch (e) {
      print("MULTIPART API ERROR [$endpoint]: $e");
      rethrow;
    }
  }
}
