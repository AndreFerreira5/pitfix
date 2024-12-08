import 'package:pitfix_frontend/src/models/user_update.dart';

import '../utils/api_client.dart';
import 'dart:convert';
import '../models/user.dart';  // Import the User model

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

  // Login method
  Future<LoginResponse?> login(String username, String password) async {
    try {
      final response = await apiClient.post('/auth/login', body: {
        'username': username,
        'password': password,
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

  // Register method
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

  // Get user data by ID
  Future<User?> getUserById(String userId, String accessToken) async {
    try {
      final response = await apiClient.get(
        '/user/$userId', // The endpoint to fetch user by ID
        headers: {
          'Authorization': 'Bearer $accessToken', // Pass the access token in the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);  // Assuming you have a User.fromJson constructor
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  // Update user profile by user ID
  Future<String> updateUserProfile(String userId, String accessToken, UserUpdate userUpdate) async {
    final response = await apiClient.put(
      '/user/$userId',  // The endpoint to update user by ID
      headers: {
        'Authorization': 'Bearer $accessToken',  // Include access token for authentication
      },
      body: json.encode(userUpdate.toJson()), // Send the updated user data
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['message'];  // Assuming the response contains a message
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to update user profile');
    }
  }
}
