// frontend/lib/src/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  String? _userRole;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userRole => _userRole;

  bool get isAuthenticated => _accessToken != null;

  Future<void> loadTokens() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
    _userRole = await _storage.read(key: 'user_role');
    notifyListeners();
  }

  Future<void> login({
    required String accessToken,
    required String refreshToken,
    required String userRole,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userRole = userRole;

    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'user_role', value: userRole);

    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _userRole = null;

    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_role');

    notifyListeners();
  }
}
