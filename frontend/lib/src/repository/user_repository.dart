import 'dart:convert';
import '../utils/api_client.dart';
import '../models/user.dart';
import '../models/user_update.dart';
import '../models/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserRepository {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Store the username and token after login
  String? username;
  String? accessToken;

  UserRepository({required this.apiClient}) {
    _loadCredentials(); // Load credentials on initialization
  }

  // Load the stored credentials (e.g., from secure storage)
  Future<void> _loadCredentials() async {
    username = await secureStorage.read(key: 'username');
    accessToken = await secureStorage.read(key: 'access_token');
  }

  // Save credentials to secure storage
  Future<void> _saveCredentials(String username, String accessToken) async {
    await secureStorage.write(key: 'username', value: username);
    await secureStorage.write(key: 'access_token', value: accessToken);
    this.username = username;
    this.accessToken = accessToken;
  }

  // Modify the login method to use the User model if needed
  Future<AuthTokens?> login(String username, String password) async {
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
                firstItem.containsKey('access_token_exp') &&
                firstItem.containsKey('refresh_token') &&
                firstItem.containsKey('refresh_token_exp')) {
              final authTokens = AuthTokens.fromJson(firstItem);
              await _saveCredentials(username, authTokens.accessToken); // Save credentials securely
              return authTokens;
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

  // Register method now returns a User object or success response
  Future<String?> register({
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
                return message;
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

  // Fetch user profile by the logged-in user's username
  Future<User?> get_user_profile() async {
    print(username);
    print(accessToken);
    if (username == null || accessToken == null) {
      throw Exception('User is not logged in');
    }

    try {
      final response = await apiClient.get(
        '/user/profile/$username', // Use the stored username in the URL
        headers: {'Authorization': 'Bearer $accessToken'}, // Include token in the headers
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData); // Return the User model object
      } else {
        return null; // Handle failure case
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

  Future<String?> getUserRole(String username) async {
    if (accessToken == null) {
      throw Exception("User is not logged in");
    }

    final response = await apiClient.get(
      '/user/$username/role',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      print(json.decode(response.body)[0]['role']);
      return json.decode(response.body)[0]['role'];
    } else {
      throw Exception('Failed to fetch user role');
    }
  }

  // Logout method to clear credentials and reset the session
  Future<void> logout() async {
    await secureStorage.delete(key: 'username');
    await secureStorage.delete(key: 'access_token');
    username = null;
    accessToken = null;
    print('User logged out');
  }
}
