import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/workshop.dart';
import '../repository/workshop_repository.dart';

class AddWorkshopPage extends StatefulWidget {
  @override
  _AddWorkshopPageState createState() => _AddWorkshopPageState();
}

class _AddWorkshopPageState extends State<AddWorkshopPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final WorkshopRepository _workshopRepository = Get.find<WorkshopRepository>();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newWorkshop = Workshop(
        name: _nameController.text,
        description: _descriptionController.text,
        rating: double.tryParse(_ratingController.text),
        imageUrl: _imageUrlController.text,
      );

      // Add the workshop using the repository
      final result = await _workshopRepository.addWorkshop(newWorkshop);

      if (result != null) {
        // Successfully added, navigate back with success result
        Navigator.pop(context, true);
      } else {
        // Handle failure (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add workshop')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workshop"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title for better visual separation
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Add New Workshop",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              // Name Field
              _buildRoundedTextField(
                controller: _nameController,
                label: "Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a workshop name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              _buildRoundedTextField(
                controller: _descriptionController,
                label: "Description",
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Rating Field
              _buildRoundedTextField(
                controller: _ratingController,
                label: "Rating",
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final rating = double.tryParse(value);
                    if (rating == null || rating < 0 || rating > 5) {
                      return 'Please enter a rating between 0 and 5';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL Field
              _buildRoundedTextField(
                controller: _imageUrlController,
                label: "Image URL",
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Add Workshop",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build rounded text fields
  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ratingController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}