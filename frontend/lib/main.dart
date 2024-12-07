import 'package:flutter/material.dart';
import 'src/ui/navigation_menu.dart';
import 'src/bindings/repository_binding.dart';
import 'package:get/get.dart';

void main() {
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
      home: NavigationMenu(userRole: "admin",), // TODO change this to the login page object and get the user info from the backend response in the form of the authentication token and extract the info from the user from there and pass it to the safe storage using flutter to always be accessible in all the codebase (the user role for exampl, to display the app based on the role)
    );
  }
}
