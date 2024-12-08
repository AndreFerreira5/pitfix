import 'dart:convert';
import '../utils/api_client.dart';
import '../models/user.dart';
import '../models/user_update.dart';  // Assuming you have the UserUpdate model for profile updates

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

  // Store the username after login
  String? username;

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
        'role': role,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if the response is a List and contains at least one item
        if (responseData is List && responseData.isNotEmpty) {
          // Get the first item of the list, which should be a Map
          var firstItem = responseData[0];

          if (firstItem is Map<String, dynamic>) {
            // Check if the message indicates success or error
            if (firstItem.containsKey('message')) {
              String message = firstItem['message'];

              // If user creation was successful
              if (message == 'User created successfully.') {
                return User(username: username, email: email, role: role);
              } else {
                print('Error: $message');
                return null;  // Handle any errors accordingly (e.g., user already exists)
              }
            }
          }
        }
      }
      return null; // If response is neither a List nor a valid Map
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Failed to register: $e');
    }
  }


  // Fetch user profile by username (from token)
  Future<User?> getUserByUsername(String accessToken) async {
    try {
      final response = await apiClient.get(
        '/user/profile',  // Route to fetch user profile by username
        headers: {
          'Authorization': 'Bearer $accessToken', // Pass token in Authorization header
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  // Update user profile by username (using token)
  Future<String> updateUserProfile(String accessToken, UserUpdate userUpdate) async {
    final response = await apiClient.put(
      '/user/profile',  // Update route using username (via token)
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(userUpdate.toJson()),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['message']; // Success message
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to update user profile');
    }
  }
}
