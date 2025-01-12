import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../repository/user_repository.dart';
import '../utils/api_client.dart';
import 'navigation_menu.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _password = '';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });

      try {
        var loginSuccessful = await AuthController.to.login(_username, _password);
        if (loginSuccessful) {
          AuthController.to.isLoggedIn.value = true;
          // Navigation is handled reactively in main.dart via Obx
          Get.snackbar('Success', 'Login successful!',
              snackPosition: SnackPosition.TOP);

          //await AuthController.to.loadUserRole(_username);
          Get.offAll(() => const NavigationMenu());
        }
      } catch (e) {
        // Errors are handled inside AuthController
        Get.snackbar('Error', 'Login failed: $e',
            snackPosition: SnackPosition.TOP);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegister() {
    Get.to(() => RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 112,
                  width: 430,
                ),
                SizedBox(height: 32),

                // "Welcome" Title Text
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),

                // Email Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  onSaved: (value) {
                    _username = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    //if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    //  return 'Please enter a valid email';
                    //}
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Password Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  onSaved: (value) {
                    _password = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                    EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                      : Text(
                    'Login',
                    style:
                    TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),

                // Navigate to Register Page
                TextButton(
                  onPressed: _navigateToRegister,
                  child: Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
