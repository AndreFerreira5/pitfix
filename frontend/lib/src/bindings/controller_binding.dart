import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    // initialize and inject controllers
    Get.put<AuthController>(AuthController());
  }
}
