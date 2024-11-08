import '../utils/api_client.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  Future<String?> login(String username, String password) async {
    final response = await apiClient.post('/auth/login', body: {
      'username': username,
      'password': password
    });

    if(response.statusCode == 200) {
      print(response.body);
      return response.body;
    }
    return null;
  }

  // TODO register
}