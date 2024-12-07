// lib/src/repository/user_repository.dart

import '../utils/api_client.dart';
import 'dart:convert';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String userRole;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userRole,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      userRole: json['user_role'],
    );
  }
}

class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  Future<LoginResponse?> login(String username, String password) async {
    try {
      final response = await apiClient.post('/auth/login', body: {
        'username': username,
        'password': password
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('access_token') &&
            responseData.containsKey('refresh_token') &&
            responseData.containsKey('user_role')) {
          return LoginResponse.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await apiClient.post('/auth/register', body: {
        'username': username,
        'password': password,
        'email': email,
        'role': role, // Include role in the request
      });

      if (response.statusCode == 201) { // 201 Created is returned on success
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

// TODO: other methods
}
