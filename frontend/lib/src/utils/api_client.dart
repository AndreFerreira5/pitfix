import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiClient({required this.baseUrl, this.defaultHeaders = const {}});

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {...defaultHeaders, if(headers != null) ...headers},
    );
    _checkForErrors(response);
    return response;
  }


  Future<http.Response> post(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        ...defaultHeaders,
        ...?headers
      },
      body: body is Map ? jsonEncode(body) : body,
    );
    _checkForErrors(response);
    return response;
  }

  void _checkForErrors(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API request failed with status: ${response.statusCode}');
    }
  }
}