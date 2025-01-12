import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';

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
              Get.snackbar('Error', 'Login failed: Invalid credentials',
                  snackPosition: SnackPosition.TOP);
              print('Login failed: Invalid credentials');
              return null;  // Invalid credentials
            }
          }
        }
      }

      print('Failed to login: ${response.statusCode}');
      Get.snackbar('Error', 'Failed to login: ${response.statusCode}',
          snackPosition: SnackPosition.TOP);
      return null;
    } catch (e) {
      Get.snackbar('Error', '$e',
          snackPosition: SnackPosition.TOP);
      print('Error during login: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getRequestsByUsername(String username) async {
    if (accessToken == null) {
      throw Exception("User is not logged in");
    }

    try {
      final response = await apiClient.get(
        '/assistance_request/worker/username/$username',
        headers: {'Authorization': 'Bearer $accessToken'}, // Include token if required
      );

      if (response.statusCode == 200) {
        print(json.decode(response.body)[0]);
        final List<dynamic> requestsData = json.decode(response.body)[0];
        return requestsData;
      } else {
        throw Exception('Failed to fetch requests');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  // Register method now returns a User object or success response
  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
    String? billing_address,
    String? workshop_id,
    String? name,
  }) async {
    try {
      // Construct the request body dynamically based on role
      final requestBody = {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      };

      if (name != null && name.isNotEmpty) requestBody['name'] = name;
      if (phone != null && phone.isNotEmpty) requestBody['phone'] = phone;
      if (address != null && address.isNotEmpty) requestBody['address'] = address;

      if (role == 'client' && billing_address != null && billing_address.isNotEmpty) {
        requestBody['billing_address'] = billing_address; // Changed from 'billingAddress'
      }

      if ((role == 'worker' || role == 'manager') && workshop_id != null && workshop_id.isNotEmpty) {
        requestBody['workshop_id'] = workshop_id; // Changed from 'workshopId'
      }

      print('Register Request Body: $requestBody');

      // Make the POST request to the backend with JSON encoding and appropriate headers
      final response = await apiClient.post(
        '/auth/register',
        headers: {'Content-Type': 'application/json'}, // Ensure JSON content type
        body: json.encode(requestBody), // Encode body as JSON
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body)[0];

        // Check if the response contains a success message
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message')) {
            String message = responseData['message'];

            // If user creation was successful
            if (message == 'User created successfully.') {
              return message;
            } else {
              print('Error: $message');
              return null; // Handle errors (e.g., user already exists)
            }
          }
        }
      } else {
        // Log the full response for debugging
        print('Failed to register. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      return null; // Handle unexpected response format
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
        '/user/$username', // Use the stored username in the URL
        headers: {'Authorization': 'Bearer $accessToken'}, // Include token in the headers
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        print(userData);
        return User.fromJson(userData); // Return the User model object
      } else {
        return null; // Handle failure case
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<String> updateUserProfile(UserUpdate userUpdate) async {
    if (username == null || accessToken == null) {
      throw Exception("User is not logged in");
    }

    try {
      // Send request to update user by username
      final response = await apiClient.put(
        '/user/update/$username',
        headers: {'Authorization': 'Bearer $accessToken'},  // Include token
        body: json.encode(userUpdate.toJson()),  // Send the updated data as JSON
      );

      // Handle response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          return responseData['message']; // Return success message
        } else {
          throw Exception("Unexpected response format");
        }
      } else if (response.statusCode == 400) {
        throw Exception("Bad request: No changes made or invalid data");
      } else if (response.statusCode == 404) {
        throw Exception("User not found");
      } else {
        throw Exception("Failed to update user profile: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error updating user profile: $e");
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

  Future<List<String>?> getUserRequestsIds(String username) async {
    if (accessToken == null) {
      throw Exception("User is not logged in");
    }

    final response = await apiClient.get(
      '/user/$username/requests',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      print(decodedResponse[0]['requests']);
      var requests = decodedResponse[0]['requests'];
      print(requests);
      if (requests != null) {
        List<String> stringRequests = List<String>.from(requests.map((e) => e.toString()));
        print(stringRequests);
        return stringRequests;
      } else {
        return null;
      }

      print(json.decode(response.body)[0]['requests']);
      print(json.decode(response.body)[0]['requests'] is List<String>);
      return json.decode(response.body)[0]['requests'];
    } else {
      throw Exception('Failed to fetch user requests');
    }
  }

  Future<List<String>> getFavoriteWorkshops() async {
    if (username == null || accessToken == null) {
      throw Exception("User is not logged in");
    }

    final response = await apiClient.get(
      '/user/$username/favorites',
      headers: {'Authorization': 'Bearer $accessToken'}, // Add token if required
    );
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch favorite workshops');
    }
  }


  Future<void> addFavoriteWorkshop(String workshopId) async {
    print(username);
    print(workshopId);
    if (username == null || accessToken == null) {
      throw Exception("User is not logged in");
    }

    final response = await apiClient.post(
      '/user/$username/favorites',
      body: {
        'username': username,
        'workshop_id': workshopId
      },
    );

    print(response.body);
    if (response.statusCode != 200) {
      throw Exception('Failed to add favorite workshop');
    }
  }

  Future<void> removeFavoriteWorkshop(String workshopId) async {
    if (username == null || accessToken == null) {
      throw Exception("User is not logged in");
    }

    final response = await apiClient.delete('/user/$username/favorites?workshop_id=$workshopId');
    if (response.statusCode != 200) {
      throw Exception('Failed to remove favorite workshop');
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

  Future<String?> getManagerWorkshopId(String username) async {
    if (accessToken == null) {
      throw Exception("User is not logged in");
    }

    final response = await apiClient.get(
      '/user/$username/workshop-id',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)[0]['workshop_id'];
    }else if(response.statusCode == 404){
      throw Exception("Manager does not have a workshop ID assigned.");
    }
    else {
      throw Exception('Failed to fetch user data');
    }
  }

  Future<List<Map<String, dynamic>>?> getAllWorkshops() async {
    try {
      // Make the API call
      final response = await apiClient.get('/workshop/all');

      // Debugging: Print the raw response
      print("Raw response body: ${response.body}");

      // Decode the JSON response body
      final dynamic decodedResponse = json.decode(response.body);

      // Ensure the response is a list
      if (decodedResponse is List && decodedResponse.isNotEmpty) {
        final dynamic firstElement = decodedResponse.first;

        // Debugging: Print the first element
        print("First element of response: $firstElement");

        // Check for a "body" key and decode it
        if (firstElement is Map<String, dynamic> && firstElement.containsKey('body')) {
          final dynamic rawBody = firstElement['body'];

          // Debugging: Print raw body
          print("Raw body: $rawBody");

          // Decode the body if it's a JSON-encoded string
          final List<dynamic> body = json.decode(rawBody);

          // Ensure the body is a list
          if (body is List) {
            return body.map((workshop) {
              return {
                'id': workshop['_id'],
                'name': workshop['name'],
              };
            }).toList();
          } else {
            throw Exception('The "body" key does not contain a valid list of workshops.');
          }
        } else {
          throw Exception('The response does not contain a valid "body" key.');
        }
      } else {
        throw Exception('The response is not a valid list.');
      }
    } catch (e) {
      print("Error during workshop fetch: $e");
      throw Exception("Failed to fetch workshops: $e");
    }
  }

}
