import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageBinding extends Bindings {
  @override
  void dependencies() {
    // initialize and inject the secure storage
    Get.put(FlutterSecureStorage());
  }
}
