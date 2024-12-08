import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:pitfix_frontend/src/repository/user_repository.dart';
import 'src/controllers/auth_controller.dart';
import 'src/ui/login.dart';
import 'src/ui/navigation_menu.dart';
import 'src/bindings/repository_binding.dart';

void main() {
  // Initialize AuthController before the app starts
  //Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PitFix',
      initialBinding: RepositoryBinding(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Obx(() {
        if (AuthController.to.isAuthenticated.value) {
          return NavigationMenu(userRole: AuthController.to.userRole.value);
        } else {
          return LoginPage();
        }
      }),
    );
  }
}
