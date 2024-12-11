import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../ui/login.dart';
import '../repository/user_repository.dart';
import '../repository/auth_repository.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  var isAccessTokenExpired = true.obs;
  var isRefreshTokenExpired = true.obs;
  Timer? _timer;

  var userRole = ''.obs;


  @override
  void onInit() {
    super.onInit();

    checkAccessTokenExpiration();
    _startPeriodicTokenCheck();
  }


  @override
  void onClose() {
    _timer?.cancel(); // cancel timer when the controller is disposed
    super.onClose();
  }


  void _startPeriodicTokenCheck() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      checkAccessTokenExpiration();
    });
  }


  Future<void> checkAccessTokenExpiration() async {
    print("Checking access token expiration...");
    var accessTokenExp = await _storage.read(key: 'access_token_exp');
    if (accessTokenExp == null) {
      isAccessTokenExpired.value = true;
    } else {
      isAccessTokenExpired.value = DateTime.now().isAfter(DateTime.parse(accessTokenExp));
    }

    if(isAccessTokenExpired.value) {
      await checkRefreshTokenExpiration();

      if (isRefreshTokenExpired.value) {
        logout("Session expired", "Please log in again!");
      } else {
        await refreshTokens();
      }
    } else {
      print("Access token is not expired!");
    }
  }


  Future<void> checkRefreshTokenExpiration() async {
    var refreshTokenExp = await _storage.read(key: 'refresh_token_exp');
    if (refreshTokenExp == null) {
      isRefreshTokenExpired.value = true;
    } else {
      isRefreshTokenExpired.value = DateTime.now().isAfter(DateTime.parse(refreshTokenExp));
    }
  }


  Future<void> refreshTokens() async {
    if (!isRefreshTokenExpired.value) {
      try {
        var accessToken = await _storage.read(key: 'access_token');
        var refreshToken = await _storage.read(key: 'refresh_token');

        if (accessToken == null || refreshToken == null) {
          return; // TODO improve this and don't just return
        }

        final newTokens = await _authRepository.refreshTokens(accessToken, refreshToken);
        if (newTokens != null) {
          await _storage.write(key: 'access_token', value: newTokens.accessToken);
          await _storage.write(key: 'access_token_exp', value: newTokens.accessTokenExp);
          await _storage.write(key: 'refresh_token', value: newTokens.refreshToken);
          await _storage.write(key: 'refresh_token_exp', value: newTokens.refreshTokenExp);
          isAccessTokenExpired.value = false;
          isRefreshTokenExpired.value = false;

          print("REFRESHED ACCESS TOKEN WITH REFRESH TOKEN!");
        }
      } catch (e) {
        print('Failed to refresh access token: $e');
      }
    }
  }


  Future<void> loadPublicKey() async {
    try {
      final publicKey = await _authRepository.getPublicKey();
      if (publicKey != null) {
        await _storage.write(key: 'public_key', value: publicKey);
      } else {
        // TODO handle error
        print('Failed to load public key');
      }
    } catch (e) {
      print(e);
    }
  }

  /*
  Future<void> loadUserRole(String username) async {
    try {
      final loginResponse = await _userRepository.getUser(username);
      print("$username - $password");
      if (loginResponse != null) {
        print(loginResponse);

        // Store tokens securely
        await _storage.write(key: 'access_token', value: loginResponse.accessToken);
        await _storage.write(key: 'access_token_exp', value: loginResponse.accessTokenExp);
        await _storage.write(key: 'refresh_token', value: loginResponse.refreshToken);
        await _storage.write(key: 'refresh_token_exp', value: loginResponse.refreshTokenExp);
        return true;
      } else {
        Get.snackbar('Error', 'Invalid credentials, please try again.',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'An error occurred during login.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }*/


  Future<bool> login(String username, String password) async {
    try {
      final loginResponse = await _userRepository.login(username, password);
      print("$username - $password");
      if (loginResponse != null) {
        print(loginResponse.accessToken);
        print(loginResponse.accessTokenExp);
        print(loginResponse.refreshToken);
        print(loginResponse.refreshTokenExp);

        // Store tokens securely
        await _storage.write(key: 'access_token', value: loginResponse.accessToken);
        await _storage.write(key: 'access_token_exp', value: loginResponse.accessTokenExp);
        await _storage.write(key: 'refresh_token', value: loginResponse.refreshToken);
        await _storage.write(key: 'refresh_token_exp', value: loginResponse.refreshTokenExp);

        await _storage.write(key: 'username', value: username);

        final gotUserRole = await _userRepository.getUserRole(username);
        print(gotUserRole);
        if (gotUserRole != null) {
          userRole.value = gotUserRole;
        }
        return true;
      } else {
        Get.snackbar('Error', 'Invalid credentials, please try again.',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'An error occurred during login.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<void> logout([String? snackbarTitle, String? snackbarMessage]) async {
    isAccessTokenExpired.value = true;
    isRefreshTokenExpired.value = true;
    // TODO inform backend that the tokens are to be made invalid/unusable
    await _storage.deleteAll();

    Get.offAll(() => LoginPage());

    if(snackbarTitle != null &&snackbarMessage != null) {
      Get.snackbar(snackbarTitle, snackbarMessage,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
