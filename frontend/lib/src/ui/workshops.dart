import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/workshop_repository.dart';
import 'add_workshop.dart';
import '../models/workshop.dart';
import 'workshop_detail_page.dart'; // Add import for the details page

class Workshops extends StatefulWidget {
  final String userRole;
  const Workshops({super.key, required this.userRole});

  @override
  _WorkshopsState createState() => _WorkshopsState();
}

class _WorkshopsState extends State<Workshops> {
  late WorkshopRepository _workshopRepository;
  late Future<List<Workshop>> _workshopsFuture;
  bool isAdmin = false; // Set to true for now to simulate admin role

  @override
  void initState() {
    super.initState();
    _workshopRepository = Get.find<WorkshopRepository>();
    _workshopsFuture = _workshopRepository.getAllWorkshops();
    isAdmin = widget.userRole == 'admin'; // Check if userRole is 'admin'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workshops"),
      ),
      body: FutureBuilder<List<Workshop>>(
        future: _workshopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('No workshops available.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No workshops available.'));
          }

          final workshops = snapshot.data!;

          return ListView.builder(
            itemCount: workshops.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final workshop = workshops[index];
              return WorkshopCard(workshop: workshop, isAdmin: isAdmin); // Pass isAdmin to WorkshopCard
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddWorkshopPage()),
            );
          },
          tooltip: "Add Workshop",
          child: const Icon(Icons.add),
        ),
      )
          : null,
    );
  }
}

// Card widget to display each workshop with a clickable action
class WorkshopCard extends StatelessWidget {
  final Workshop workshop;
  final bool isAdmin; // Add isAdmin as a parameter

  const WorkshopCard({required this.workshop, required this.isAdmin, super.key}); // Make sure to accept isAdmin

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () {
          // Navigate to the WorkshopDetailsPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkshopDetailsPage(workshop: workshop, isAdmin: isAdmin), // Pass isAdmin to details page
            ),
          );
        },
        contentPadding: const EdgeInsets.all(16),
        title: Text(workshop.name),
        subtitle: Text(workshop.description ?? 'No description available'),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
