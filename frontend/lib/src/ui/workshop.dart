import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/workshop.dart';
import '../repository/workshop_repository.dart';
import 'add_request.dart';

class WorkshopDetailPage extends StatelessWidget {
  final Workshop workshop;

  WorkshopDetailPage({Key? key, required this.workshop}) : super(key: key);

  final WorkshopRepository _workshopRepository = Get.find<WorkshopRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workshop.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit workshop page or handle edit functionality
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditWorkshopPage(workshop: workshop),
                ),
              );
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
                      builder: (context) => AddRequestPage(preselectedWorkshop: workshop.name),
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

class EditWorkshopPage extends StatelessWidget {
  final Workshop workshop;

  const EditWorkshopPage({Key? key, required this.workshop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workshop'),
      ),
      body: Center(
        child: Text('Edit workshop functionality goes here'),
      ),
    );
  }
}
