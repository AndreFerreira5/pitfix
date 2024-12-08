import 'dart:convert';
import '../utils/api_client.dart';
import '../models/user.dart';
import '../models/user_update.dart';

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

  // Store the username and token after login
  String? username;
  String? accessToken;

  UserRepository({required this.apiClient});

  // Modify the login method to use the User model if needed
  Future<LoginResponse?> login(String username, String password) async {
    try {
      // Sending login request to backend
      final response = await apiClient.post('/auth/login', body: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData is List && responseData.isNotEmpty) {
          var firstItem = responseData[0];

          if (firstItem is Map<String, dynamic>) {
            if (firstItem.containsKey('access_token') &&
                firstItem.containsKey('refresh_token') &&
                firstItem.containsKey('user_role')) {
              accessToken = firstItem['access_token'];  // Store the access token
              username = firstItem['username'];  // Store the username
              return LoginResponse.fromJson(firstItem);  // Success, return LoginResponse
            }

            if (firstItem.containsKey('message') && firstItem['message'] == 'Invalid username or password') {
              print('Login failed: Invalid credentials');
              return null;  // Invalid credentials
            }
          }
        }
      }

      print('Failed to login: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Fetch user profile by the logged-in user's username
  Future<User?> get_user_profile() async {
    if (username == null || accessToken == null) {
      throw Exception("User is not logged in");
    }

    try {
      final response = await apiClient.get(
        '/user/profile/$username',  // Use the stored username in the URL
        headers: {'Authorization': 'Bearer $accessToken'},  // Pass the access token
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

  // Update user profile by username
  Future<String> updateUserProfile(UserUpdate userUpdate) async {
    if (username == null || accessToken == null) {
      throw Exception("User is not logged in");
    }

    final response = await apiClient.put(
      '/user/profile/$username',  // Use the stored username in the URL
      headers: {'Authorization': 'Bearer $accessToken'},  // Include token in the request header
      body: json.encode(userUpdate.toJson()),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['message'];
    } else {
      throw Exception('Failed to update user profile');
    }
  }
}
