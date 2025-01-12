import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/workshop.dart';
import '../repository/workshop_repository.dart';
import 'add_request.dart';

class WorkshopDetailPage extends StatefulWidget {
  final Workshop workshop;

  WorkshopDetailPage({Key? key, required this.workshop}) : super(key: key);

  @override
  State<WorkshopDetailPage> createState() => _WorkshopDetailPageState();
}

class _WorkshopDetailPageState extends State<WorkshopDetailPage> {
  late Workshop workshop;

  final WorkshopRepository _workshopRepository = Get.find<WorkshopRepository>();

  @override
  void initState() {
    super.initState();
    workshop = widget.workshop; // Initialize the workshop instance
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workshop.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to the edit workshop page and wait for the result
              final updatedWorkshop = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditWorkshopPage(workshop: workshop),
                ),
              );

              if (updatedWorkshop != null) {
                // Update the workshop details with the edited data
                setState(() {
                  workshop = updatedWorkshop; // Refresh the UI
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Handle delete functionality
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Workshop Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (workshop.imageUrl != null && workshop.imageUrl!.isNotEmpty)
                    ? Image.network(
                  workshop.imageUrl!,
                  fit: BoxFit.cover,
                )
                    : Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            // Workshop Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workshop.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        workshop.rating?.toString() ?? 'N/A',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Text(
                      workshop.description ?? 'No description available.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),

            // Add Request Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddRequestPage(preselectedWorkshop: workshop.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Request',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show confirmation dialog before deleting
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workshop'),
        content: const Text('Are you sure you want to delete this workshop?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _deleteWorkshop(context); // Call delete functionality
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteWorkshop(BuildContext context) async {
    try {
      await _workshopRepository.deleteWorkshopByName(workshop.name);

      // Show a snackbar for feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workshop deleted successfully')),
      );

      // Navigate back to the previous page after deletion
      Navigator.pop(context, true);
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete workshop: $e')),
      );
    }
  }
}


class EditWorkshopPage extends StatefulWidget {
  final Workshop workshop;

  const EditWorkshopPage({Key? key, required this.workshop}) : super(key: key);

  @override
  State<EditWorkshopPage> createState() => _EditWorkshopPageState();
}

class _EditWorkshopPageState extends State<EditWorkshopPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final WorkshopRepository _workshopRepository = Get.find<WorkshopRepository>();

  @override
  void initState() {
    super.initState();
    // Pre-fill the form fields with the existing workshop data
    _nameController.text = widget.workshop.name;
    _descriptionController.text = widget.workshop.description ?? '';
    _imageUrlController.text = widget.workshop.imageUrl ?? '';
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workshop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Workshop Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL Field
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.isAbsolute) {
                      return 'Enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveWorkshop,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveWorkshop() async {
    if (!_formKey.currentState!.validate()) {
      // If the form is invalid, stop the save process
      return;
    }

    try {
      // Create an updated workshop object
      final updatedWorkshop = Workshop(
        id: widget.workshop.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        rating: widget.workshop.rating,
      );

      // Update the workshop in the backend
      await _workshopRepository.editWorkshop(widget.workshop.id!, updatedWorkshop);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workshop updated successfully')),
      );

      // Navigate back to the previous screen with updated workshop
      Navigator.pop(context, updatedWorkshop);
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update workshop: $e')),
      );
    }
  }
}

