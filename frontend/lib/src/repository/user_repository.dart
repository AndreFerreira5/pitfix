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
      // Sending login request to backend
      final response = await apiClient.post('/auth/login', body: {
        'username': username,
        'password': password,
      });

      // Check if the status code is 200 (OK)
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Ensure the response is a List and contains at least one element
        if (responseData is List && responseData.isNotEmpty) {
          var firstItem = responseData[0];

          // Check if the first item is a map and contains the expected fields
          if (firstItem is Map<String, dynamic>) {
            // Case 1: Handle successful login response with tokens
            if (firstItem.containsKey('access_token') &&
                firstItem.containsKey('refresh_token') &&
                firstItem.containsKey('user_role')) {
              return LoginResponse.fromJson(firstItem);  // Success, return LoginResponse
            }

            // Case 2: Handle failed login response (Invalid credentials)
            if (firstItem.containsKey('message') && firstItem['message'] == 'Invalid username or password') {
              print('Login failed: Invalid credentials');
              return null;  // Invalid credentials, return null
            }
          }
        }
      }

      // If status code isn't 200 or response doesn't match expected structure
      print('Failed to login: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
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
      print(e);
      throw Exception('Failed to register: $e');
    }
  }

}

