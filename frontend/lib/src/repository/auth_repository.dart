import 'dart:convert';
import '../utils/api_client.dart';
import '../models/auth.dart';

class AuthRepository {
  final ApiClient apiClient;

  // backend public key
  String? publicKey;

  AuthRepository({required this.apiClient});

  Future<String?> getPublicKey() async {
    try {
      final response = await apiClient.get('/auth/public-key');
      print(response);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData is List && responseData.isNotEmpty) {
          var firstItem = responseData[0];
          if (firstItem is Map<String, dynamic>) {
            if (firstItem.containsKey('public_key')) {
              return firstItem['public_key'];
            }
          }
        }
      }

      return response.body;
    } catch(e) {
      print("Error getting public key: $e");
      return null;
    }
  }


  Future<AuthTokens?> refreshTokens(String accessToken, String refreshToken) async {
    try {
      final response = await apiClient.post('/auth/refresh', body: {
        'access_token': accessToken,
        'refresh_token': refreshToken,
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
              return AuthTokens.fromJson(firstItem);
            }
          }
        }
      } else {
        print('Failed to refresh tokens: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during refresh: $e');
      return null;
    }
    return null;
  }
}