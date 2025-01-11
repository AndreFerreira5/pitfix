import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/workshop.dart';
import 'add_request.dart';

class WorkshopDetailPage extends StatelessWidget {
  final Workshop workshop;

  const WorkshopDetailPage({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workshop.name), // Use the workshop's name as the title
      ),
      body: SafeArea( // SafeArea ensures the content doesn't overlap system UI
        child: Stack( // Stack allows us to overlay the button at the bottom
          children: [
            // Main content of the page
            SingleChildScrollView( // Allows scrolling in case content overflows
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Workshop Image - Centered at the top
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: (workshop.imageUrl != null && workshop.imageUrl!.isNotEmpty)
                          ? Image.network(
                        workshop.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                      )
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
                    // Workshop name below the image
                    Text(
                      workshop.name,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87
                      ), // Adjusted for visibility
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Centered rating
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          workshop.rating?.toString() ?? 'N/A',
                          style: Theme.of(context).textTheme.bodyMedium, // Updated
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Description Section with a Title ("Description:")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Description:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 18,
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
                            style: Theme.of(context).textTheme.bodyMedium, // Updated
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 80), // Add some space at the bottom for the button
                  ],
                ),
              ),
            ),
            // The "Add Request" button at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0), // Padding to ensure button has margins
                child: Container(
                  width: double.infinity, // Makes the button span the full width
                  child: ElevatedButton(
                    onPressed: () {
                      // Button functionality can be added here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.6), // Translucent blue background
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddRequestPage(preselectedWorkshop: workshop.name),
                          ),
                        );
                      },
                      tooltip: "Add Request",
                      child: const Icon(Icons.add),
                    ),

                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
