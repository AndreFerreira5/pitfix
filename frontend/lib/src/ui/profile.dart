import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_update.dart';
import '../repository/user_repository.dart';

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

  bool _isEditing = false;
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _billingController = TextEditingController();

  late UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _userRepository = Get.find<UserRepository>(); // Get the repository instance
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _billingController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userProfile = await _userRepository.get_user_profile();
      const String placeholderText = '--';
      setState(() {
        _name = userProfile?.name ?? placeholderText;
        _email = userProfile?.email ?? placeholderText;
        _phone = userProfile?.phone ?? placeholderText;
        _address = userProfile?.address ?? placeholderText;
        _billingAddress = userProfile is Client ? userProfile.billingAddress ?? placeholderText : '';
        _isLoading = false;

        // Initialize controllers with the fetched data
        _nameController.text = _name;
        _emailController.text = _email;
        _phoneController.text = _phone;
        _addressController.text = _address;
        _billingController.text = _billingAddress;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Failed to load profile: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _saveChanges() async {
    if (!_validateInputs()) return;

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
      );

      final result = await _userRepository.updateUserProfile(userUpdate);

      // Fetch the updated profile to refresh the page
      await _fetchUserProfile();

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      Get.snackbar('Success', result, snackPosition: SnackPosition.BOTTOM);
      print("Profile updated successfully: $result");
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Get.snackbar('Error', 'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        !_emailController.text.contains('@') ||
        _phoneController.text.isEmpty) {
      Get.snackbar(
        'Invalid Input',
        'Please fill in all fields correctly',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          obscureText: label == 'Password',
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
