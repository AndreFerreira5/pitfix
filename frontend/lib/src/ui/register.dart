import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/user_repository.dart';
import '../utils/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'login.dart';
import '../utils/country_codes.dart';


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
  String? _phone = '';
  String? _address = '';
  String? _billingAddress = '';
  String? _workshopId = '';
  String? _name = '';
  String _selectedRole = 'client';
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedCountryCode = '+1'; // Default country code

  final List<String> _roles = ['client', 'manager', 'worker', 'admin'];
  final Map<String, String> _countryCodes = countryCodes;

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final responseMessage = await userRepository.register(
          username: _username,
          email: _email,
          password: _password,
          role: _selectedRole,
          phone: '$_selectedCountryCode $_phone',
          address: _address,
          billingAddress: _selectedRole == 'client' ? _billingAddress : null,
          workshopId: _selectedRole == 'worker' || _selectedRole == 'manager' ? _workshopId : null,
          name: _name,
        ).timeout(Duration(seconds: 5), onTimeout: () {
          throw TimeoutException("Connection timed out. Please try again.");
        });

        if (responseMessage == 'User created successfully.') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar('Success', 'Registration successful! Please login.',
                snackPosition: SnackPosition.TOP);
            Get.offAll(() => LoginPage());
          });
        } else {
          Get.snackbar('Error', responseMessage ?? 'Registration failed.',
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
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                // NavigationBar at the top
                NavigationBarTheme(
                  data: NavigationBarThemeData(
                    indicatorShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded edges
                    ),
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  ),
                  child: NavigationBar(
                    selectedIndex: _roles.indexOf(_selectedRole),
                    onDestinationSelected: (index) {
                      setState(() {
                        _selectedRole = _roles[index];
                      });
                    },
                    destinations: [
                      NavigationDestination(
                        icon: Icon(Icons.person_outline),
                        label: 'Client',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.business_center),
                        label: 'Manager',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.construction),
                        label: 'Worker',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.admin_panel_settings),
                        label: 'Admin',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _name = value ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _username = value ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
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
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
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
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Country Code',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCountryCode,
                        items: _countryCodes.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.value,
                            child: Text('${entry.key} (${entry.value})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountryCode = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Phone (Not required)',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _phone = value;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _address = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                if (_selectedRole == 'client')
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Billing Address',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      _billingAddress = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your billing address';
                      }
                      return null;
                    },
                  ),
                if (_selectedRole == 'worker' || _selectedRole == 'manager')
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Workshop ID',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      _workshopId = value;
                    },
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Register'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blueAccent,
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
