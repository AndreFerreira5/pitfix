import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../ui/login.dart';

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();

  ApiClient({required this.baseUrl, this.defaultHeaders = const {}});

  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _buildHeaders(headers),
    );
    _handleErrors(response);
    return response;
  }

  Future<http.Response> post(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _buildHeaders(headers),
      body: body is Map ? jsonEncode(body) : body,
    );
    _handleErrors(response);
    return response;
  }

  Future<http.Response> put(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _buildHeaders(headers),
      body: body is Map ? jsonEncode(body) : body,
    );
    _handleErrors(response);
    return response;
  }

  Future<http.Response> delete(String endpoint,
      {Map<String, String>? headers}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _buildHeaders(headers),
    );
    _handleErrors(response);
    return response;
  }

  Future<Map<String, String>> _buildHeaders(Map<String, String>? headers) async {
    final authController = AuthController.to;
    Map<String, String> combinedHeaders = {
      'Content-Type': 'application/json',
      ...defaultHeaders,
      if (headers != null) ...headers,
    };

    var accessToken = await _storage.read(key: 'access_token');
    if (accessToken != null) {
      combinedHeaders['Authorization'] = 'Bearer $accessToken';
    } else {
      await authController.refreshTokens();
      var accessToken = await _storage.read(key: 'access_token');
      if (accessToken != null) {
        combinedHeaders['Authorization'] = 'Bearer $accessToken';
      }
    }

    return combinedHeaders;
  }

  void _handleErrors(http.Response response) {
    if (response.statusCode == 401) {
      // Unauthorized - possibly token expired
      Get.snackbar('Session Expired', 'Please log in again.',
          snackPosition: SnackPosition.TOP);
      AuthController.to.logout();
    } else if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API request failed with status: ${response.statusCode}');
    }
  }
}
