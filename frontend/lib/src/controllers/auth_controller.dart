import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../ui/login.dart';
import '../repository/user_repository.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final UserRepository _userRepository = Get.find<UserRepository>();

  var accessToken = ''.obs;
  var refreshToken = ''.obs;
  var userRole = ''.obs;
  var isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTokens();
  }

  Future<void> loadTokens() async {
    accessToken.value = await _storage.read(key: 'access_token') ?? '';
    refreshToken.value = await _storage.read(key: 'refresh_token') ?? '';
    userRole.value = await _storage.read(key: 'user_role') ?? '';
    isAuthenticated.value = accessToken.value.isNotEmpty;
  }

  Future<void> login(String username, String password) async {
    try {
      final loginResponse = await _userRepository.login(username, password);
      if (loginResponse != null) {
        accessToken.value = loginResponse.accessToken;
        refreshToken.value = loginResponse.refreshToken;
        userRole.value = loginResponse.userRole;
        isAuthenticated.value = true;

        // Store tokens securely
        await _storage.write(key: 'access_token', value: accessToken.value);
        await _storage.write(key: 'refresh_token', value: refreshToken.value);
        await _storage.write(key: 'user_role', value: userRole.value);
      } else {
        Get.snackbar('Error', 'Invalid credentials, please try again.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'An error occurred during login.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    accessToken.value = '';
    refreshToken.value = '';
    userRole.value = '';
    isAuthenticated.value = false;

    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_role');

    Get.offAll(() => LoginPage());
  }
}
