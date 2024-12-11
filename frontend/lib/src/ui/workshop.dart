import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/workshop.dart';

class WorkshopDetailPage extends StatelessWidget {
  final Workshop workshop;

  const WorkshopDetailPage({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workshop.name), // Use the workshop's name as the title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workshop Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: (workshop.imageUrl != null && workshop.imageUrl!.isNotEmpty)
                  ? Image.network(workshop.imageUrl!, fit: BoxFit.cover)
                  : Container(
                color: Colors.grey[200],
                height: 250,
                child: const Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Workshop name
            Text(
              workshop.name,
              style: Theme.of(context).textTheme.headlineMedium, // updated
            ),
            const SizedBox(height: 8),
            // Rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(workshop.rating?.toString() ?? 'N/A',
                    style: Theme.of(context).textTheme.bodyLarge), // updated
              ],
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              workshop.description ?? 'No description available.',
              style: Theme.of(context).textTheme.bodyMedium, // updated
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            // Additional Info (only if it exists)

          ],
        ),
      ),
    );
  }
}
