import '../utils/api_client.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/login_response.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  // Modify the login method to use the User model if needed
  Future<LoginResponse?> login(String email, String password) async {
    final response = await apiClient.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);

      // Check if the response is a List
      if (responseData is List && responseData.isNotEmpty) {
        // Access the first element, which should be a Map
        var messageMap = responseData[0];

        if (messageMap is Map<String, dynamic>) {
          // Handle the case where login failed (e.g., Invalid username or password)
          if (messageMap.containsKey('message') && messageMap['message'] == 'Invalid username or password') {
            print('Login failed: Invalid credentials');
            return null;
          }
        }
      }
    }
    return null;
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

