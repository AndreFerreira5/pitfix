import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Sample user data
  String _name = "John Doe";
  String _email = "john.doe@example.com";
  String _phone = "+1234567890";
  String _address = "123 Main St, Springfield, USA";
  String _billingAddress = "456 Elm St, Springfield, USA";

  // Boolean to toggle between view and edit mode
  bool _isEditing = false;

  // Controllers to manage the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _billingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize text fields with current user data
    _nameController.text = _name;
    _emailController.text = _email;
    _phoneController.text = _phone;
    _addressController.text = _address;
    _billingController.text = _billingAddress;
  }

  @override
  void dispose() {
    // Dispose of controllers when the widget is disposed
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _billingController.dispose();
    super.dispose();
  }

  // Function to toggle between edit and view modes
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // Function to save the changes (for now, just print the new values)
  void _saveChanges() {
    setState(() {
      _name = _nameController.text;
      _email = _emailController.text;
      _phone = _phoneController.text;
      _address = _addressController.text;
      _billingAddress = _billingController.text;
      _isEditing = false; // Exit edit mode
    });

    // For now, print the updated values (replace with your save logic)
    print("Saved Changes:");
    print("Name: $_name");
    print("Email: $_email");
    print("Phone: $_phone");
    print("Address: $_address");
    print("Billing Address: $_billingAddress");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section Header
              const Text(
                'Profile Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Name
              _buildTextField(
                label: 'Name',
                controller: _nameController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 16),

              // Phone Number
              _buildTextField(
                label: 'Phone Number',
                controller: _phoneController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 16),

              // Address
              _buildTextField(
                label: 'Address',
                controller: _addressController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 16),

              // Billing Address
              _buildTextField(
                label: 'Billing Address',
                controller: _billingController,
                isEditable: _isEditing,
              ),
              const SizedBox(height: 24),

              // Edit/Save Button
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

  // Widget to display each text field with a label and controller
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
