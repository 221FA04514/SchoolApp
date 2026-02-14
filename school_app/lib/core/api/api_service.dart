import 'dart:convert';
<<<<<<< HEAD
import 'package:dio/dio.dart' as dio_lib;
=======
import 'dart:async';
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
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
        return data;
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
        return data;
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
        return data;
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
        return data;
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

<<<<<<< HEAD
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
        return response.data;
      } else {
        throw ApiException(
          response.data["message"] ?? "Upload error",
          response.statusCode!,
          response.data,
        );
      }
    } catch (e) {
      print("MULTIPART API ERROR [$endpoint]: $e");
=======
  // ================= UPLOAD =================
  Future<dynamic> uploadFile(
    String endpoint,
    Map<String, String> fields,
    String? filePath,
    String fileField,
  ) async {
    try {
      final uri = Uri.parse("${AppConstants.baseUrl}$endpoint");
      final request = http.MultipartRequest("POST", uri);

      // Headers
      final token = await _getToken();
      if (token != null) {
        request.headers["Authorization"] = "Bearer $token";
      }

      // Fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // File
      if (filePath != null) {
        final file = await http.MultipartFile.fromPath(fileField, filePath);
        request.files.add(file);
      }

      final streamResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Upload failed");
      }
    } on TimeoutException {
      throw Exception("Server timeout. Please try again.");
    } catch (e) {
      print("UPLOAD ERROR [$endpoint]: $e");
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
      rethrow;
    }
  }
}
