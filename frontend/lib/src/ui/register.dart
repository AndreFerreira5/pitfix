import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/user_repository.dart';
import '../utils/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository userRepository = Get.find<UserRepository>();
  final FlutterSecureStorage storage = Get.find<FlutterSecureStorage>();

  String _username = '';
  String _email = '';
  String _password = '';
  String? _selectedRole;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final List<String> _roles = ['client', 'manager', 'worker', 'admin'];

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a role')),
        );
        return;
      }

      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await userRepository.register(
          username: _username,
          email: _email,
          password: _password,
          role: _selectedRole!,
        ).timeout(Duration(seconds: 5), onTimeout: () {
          throw TimeoutException("Connection timed out. Please try again.");
        });

        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar('Success', 'Registration successful! Please login.',
                snackPosition: SnackPosition.TOP);
            Get.offAll(() => LoginPage());
          });
        } else {
          Get.snackbar('Error', 'Registration failed. Please try again.',
              snackPosition: SnackPosition.TOP);
        }
      } on TimeoutException catch (e) {
        Get.snackbar('Error', e.message ?? 'Request timed out',
            snackPosition: SnackPosition.TOP);
      } catch (e) {
        print(e);
        Get.snackbar('Error', 'An unexpected error occurred.',
            snackPosition: SnackPosition.TOP);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 112,
                  width: 430,
                ),
                SizedBox(height: 32),
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _username = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) {
                    _email = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                SizedBox(height: 30),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedRole,
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(
                        role[0].toUpperCase() + role.substring(1),
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Register'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), backgroundColor: Colors.blueAccent,
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
