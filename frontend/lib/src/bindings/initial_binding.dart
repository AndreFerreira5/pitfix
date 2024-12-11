import 'package:get/get.dart';
import 'repository_binding.dart';
import 'controller_binding.dart';
import 'secure_storage_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    SecureStorageBinding().dependencies();
    RepositoryBinding().dependencies();
    ControllerBinding().dependencies();
  }
}
