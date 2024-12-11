import 'package:get/get.dart';
import 'package:paseto/paseto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthUtils extends GetxController {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();

  Future<DateTime?> getTokenExpiration(String key) async {
    final expString = await _storage.read(key: key);
    if (expString == null) return null;
    return DateTime.parse(expString);
  }

  Future<bool> isTokenExpired(String key) async {
    final expDate = await getTokenExpiration(key);
    if (expDate == null) return true;
    return DateTime.now().isAfter(expDate);
  }

  Future<void> deleteTokens() async {
    await _storage.deleteAll();
  }
}