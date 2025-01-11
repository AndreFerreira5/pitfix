import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/controllers/auth_controller.dart';
import 'src/ui/login.dart';
import 'src/ui/navigation_menu.dart';
import 'src/bindings/initial_binding.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PitFix',
      initialBinding: InitialBinding(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('pt'), // Portuguese
        Locale('es'), // Spanish
      ],
      home: Obx(() {
        final isAccessExpired = AuthController.to.isAccessTokenExpired.value;
        final isRefreshExpired = AuthController.to.isRefreshTokenExpired.value;

        if(isAccessExpired){
          print("access token expired");
          if(isRefreshExpired){
            print("refresh token expired");
            return LoginPage();
          } else {
            AuthController.to.refreshTokens();
          }
        }

        return const NavigationMenu();
      }),
    );
  }
}
