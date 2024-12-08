import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/workshop.dart';
import '../repository/workshop_repository.dart';
import 'add_workshop.dart';

class WorkshopDetailsPage extends StatelessWidget {
  final Workshop workshop;
  final bool isAdmin;
  final WorkshopRepository _workshopRepository = Get.find<WorkshopRepository>();

  // Constructor to receive the selected workshop
  WorkshopDetailsPage({required this.workshop, required this.isAdmin, super.key});

  // Delete the workshop
  Future<void> _deleteWorkshop(BuildContext context) async {
    try {
      await _workshopRepository.deleteWorkshop(workshop.name); // Adjust based on actual 'id' or name
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workshop deleted successfully')),
      );
      Navigator.pop(context); // Go back to the previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete workshop: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workshop.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (workshop.imageUrl != null && workshop.imageUrl!.isNotEmpty)
                  ? Image.network(workshop.imageUrl!, width: double.infinity, height: 200, fit: BoxFit.cover)
                  : Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Text(workshop.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(workshop.description ?? 'No description available', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(workshop.rating?.toString() ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 24),

            if (isAdmin) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWorkshopPage(),
                        ),
                      );
                    },
                    child: const Text("Edit Workshop"),
                  ),
                  ElevatedButton(
                    onPressed: () => _deleteWorkshop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text("Delete Workshop"),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
