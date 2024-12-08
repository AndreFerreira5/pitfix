import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/user_repository.dart';
import '../utils/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository userRepository = UserRepository(apiClient: ApiClient(baseUrl: 'http://127.0.0.1:8000'));
  final FlutterSecureStorage storage = FlutterSecureStorage();

  String _username = '';
  String _address = '';
  String _email = '';
  String _password = '';
  String? _selectedRole; // New state variable for role
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Define the list of roles
  final List<String> _roles = ['client', 'manager', 'worker', 'admin'];

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRole == null) {
        // If role is not selected, show an error
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
        final success = await userRepository
            .register(
          username: _username, // Changed from _name to _username
          email: _email,
          password: _password,
          role: _selectedRole!, // Pass the selected role
        )
            .timeout(Duration(seconds: 5), onTimeout: () {
          throw TimeoutException("Connection timed out. Please try again.");
        });

        if (success) {
          // Optionally, you can auto-login the user or navigate them to the login page
          Get.snackbar('Success', 'Registration successful! Please login.',
              snackPosition: SnackPosition.BOTTOM);
          Get.back(); // Navigate back to login page using GetX
          // Alternatively, use Navigator.pop(context);
        } else {
          Get.snackbar('Error', 'Registration failed. Please try again.',
              snackPosition: SnackPosition.BOTTOM);
          // Alternatively, use ScaffoldMessenger
        }
      } on TimeoutException catch (e) {
        Get.snackbar('Error', e.message ?? 'Request timed out',
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Error', 'An unexpected error occurred.',
            snackPosition: SnackPosition.BOTTOM);
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
          child: SingleChildScrollView( // To handle overflow when keyboard appears
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                  height: 112,
                  width: 430,
                ),
                SizedBox(height: 32),

                // "Register" Title Text
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),

                // Name Field
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

                // Address Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _address = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Email Field
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

                // Password Field
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

                // Role Selection Dropdown
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
                SizedBox(height: 30),

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
                    'Register',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),

                // Navigate to Login Page
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to login page
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.blueAccent),
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
