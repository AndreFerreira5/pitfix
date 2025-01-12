import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_update.dart';
import '../repository/user_repository.dart';
import '../repository/workshop_repository.dart';
import '../models/workshop.dart';

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

  bool _isEditing = false;
  bool _isLoading = true;

  List<Workshop> _favorites = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  late UserRepository _userRepository;
  late WorkshopRepository _workshopRepository;

  @override
  void initState() {
    super.initState();
    _userRepository = Get.find<UserRepository>();
    _workshopRepository = Get.find<WorkshopRepository>();
    _fetchUserProfile();
    _fetchFavoriteWorkshops();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
        _isLoading = false;

        _nameController.text = _name;
        _emailController.text = _email;
        _phoneController.text = _phone;
        _addressController.text = _address;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Failed to load profile: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _fetchFavoriteWorkshops() async {
    try {
      // Get the list of favorite workshop IDs
      final favoriteIds = await _userRepository.getFavoriteWorkshops();

      // Fetch workshop details for each ID
      final workshops = await Future.wait(
        favoriteIds.map((id) => _workshopRepository.getWorkshopById(id)),
      );

      setState(() {
        _favorites = workshops;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load favorite workshops: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _removeFavoriteWorkshop(String workshopId) async {
    try {
      await _userRepository.removeFavoriteWorkshop(workshopId);
      setState(() {
        _favorites.removeWhere((workshop) => workshop.id == workshopId);
      });
      Get.snackbar('Success', 'Workshop removed from favorites');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove favorite workshop: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 24),
              _buildFavoritesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Name', _nameController, _isEditing),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController, _isEditing),
            const SizedBox(height: 16),
            _buildTextField('Phone', _phoneController, _isEditing),
            const SizedBox(height: 16),
            _buildTextField('Address', _addressController, _isEditing),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isEditing ? _fetchUserProfile : _toggleEditMode,
                child: Text(
                  _isEditing ? 'Save Changes' : 'Edit Profile',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favorite Workshops',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            if (_favorites.isEmpty)
              const Text('No favorite workshops added.')
            else
              ..._favorites.map((workshop) => ListTile(
                title: Text(workshop.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeFavoriteWorkshop(workshop.id!),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool isEditable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: isEditable,
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: isEditable ? Colors.white : Colors.grey[200],
            hintText: 'Enter $label',
          ),
        ),
      ],
    );
  }
}
