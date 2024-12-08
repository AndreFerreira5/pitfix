import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_update.dart';
import '../repository/user_repository.dart';
import '../models/user.dart';
import '../utils/api_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "";
  String _email = "";
  String _phone = "";
  String _address = "";
  String _billingAddress = "";
  String _password = "";  // Include password in profile

  bool _isEditing = false;
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _billingController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserRepository _userRepository = UserRepository(apiClient: ApiClient(baseUrl: 'http://localhost:8000'));

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _billingController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fetch user data by the logged-in user's username
  Future<void> _fetchUserProfile() async {
    try {
      final userProfile = await _userRepository.get_user_profile();

      setState(() {
        _name = userProfile?.name ?? '';
        _email = userProfile?.email ?? '';
        _phone = userProfile?.phone ?? '';
        _address = userProfile?.address ?? '';
        _billingAddress = userProfile?.billingAddress ?? '';
        _password = userProfile?.password ?? '';  // Fetch password as well
        _isLoading = false;

        // Initialize controllers
        _nameController.text = _name;
        _emailController.text = _email;
        _phoneController.text = _phone;
        _addressController.text = _address;
        _billingController.text = _billingAddress;
        _passwordController.text = _password;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching user profile: $e");
    }
  }

  // Save changes and update user profile
  void _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userUpdate = UserUpdate(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        billingAddress: _billingController.text,
        password: _passwordController.text, // Send the updated password
      );

      final result = await _userRepository.updateUserProfile(userUpdate);

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      print("User profile updated: $result");
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error saving changes: $e");
    }
  }

  // Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Name',
                controller: _nameController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Email',
                controller: _emailController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Phone',
                controller: _phoneController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Address',
                controller: _addressController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Billing Address',
                controller: _billingController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Password',
                controller: _passwordController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isEditing ? _saveChanges : _toggleEditMode,
                child: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        isEditable
            ? TextField(
          controller: controller,
          obscureText: label == 'Password' ? true : false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter $label',
          ),
        )
            : Text(
          controller.text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
