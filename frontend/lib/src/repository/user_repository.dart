import '../utils/api_client.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/login_response.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  // Modify the login method to use the User model if needed
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

  // Register method now returns a User object or success response
  Future<User?> register({
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

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return User.fromJson(responseData);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

}

