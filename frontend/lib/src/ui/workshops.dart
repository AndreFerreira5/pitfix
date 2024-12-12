import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pitfix_frontend/src/ui/workshop.dart';
import '../repository/workshop_repository.dart';
import 'add_workshop.dart';
import '../models/workshop.dart';

class Workshops extends StatefulWidget {
  final String userRole;

  const Workshops({super.key, required this.userRole});

  @override
  _WorkshopsState createState() => _WorkshopsState();
}


class _WorkshopsState extends State<Workshops> {
  late WorkshopRepository _workshopRepository;
  late Future<List<Workshop>> _workshopsFuture;
  late bool isAdmin;

  @override
  void initState() {
    super.initState();

    _workshopRepository = Get.find<WorkshopRepository>();
    _workshopsFuture = _workshopRepository.getAllWorkshops();
    isAdmin = widget.userRole == 'admin';
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
            //return Center(child: Text('Error: ${snapshot.error}')); // TODO simply display "no workshops available" or display the error?
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No workshops available.'));
          }

          final workshops = snapshot.data!;

          return ListView.builder(
            itemCount: workshops.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final workshop = workshops[index];
              return WorkshopCard(workshop: workshop);
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


// widget to display each workshop as a card
class WorkshopCard extends StatelessWidget {
  final Workshop workshop;

  const WorkshopCard({required this.workshop, super.key});

  bool isValidUrl(String url) {
    const regex = r'^(https?|ftp)://([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/.*)?$';
    final regExp = RegExp(regex);

    return regExp.hasMatch(url);
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the detailed workshop page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkshopDetailPage(workshop: workshop),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: (workshop.imageUrl != null && workshop.imageUrl!.isNotEmpty
                        && isValidUrl(workshop.imageUrl!))
                    ? Image.network(
                  workshop.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workshop.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      workshop.description ?? 'No description available',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(workshop.rating?.toString() ?? 'N/A'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

