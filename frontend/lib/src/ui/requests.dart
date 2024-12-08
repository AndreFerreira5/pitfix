import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pitfix_frontend/src/ui/add_request.dart'; // Assuming you have this page
import '../models/assistance_request.dart';
import '../repository/assistance_request_reepository.dart'; // Assuming this repository exists

class AdminRequestsPage extends StatefulWidget {
  final String userRole;

  const AdminRequestsPage({super.key, required this.userRole});

  @override
  _AdminRequestsPageState createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  late AssistanceRequestRepository _assistanceRequestRepository;
  late Future<List<AssistanceRequest>> _assistanceRequestsFuture;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    _assistanceRequestsFuture = _assistanceRequestRepository.getAllAssistanceRequests();
    isAdmin = widget.userRole == 'admin'; // Check if the user is admin
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Assistance Requests"),
      ),
      body: FutureBuilder<List<AssistanceRequest>>(
        future: _assistanceRequestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('No requests available.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No requests available.'));
          }

          final requests = snapshot.data!;

          return ListView.builder(
            itemCount: requests.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final request = requests[index];
              return RequestCard(request: request, isAdmin: isAdmin);
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
              MaterialPageRoute(builder: (context) => const AddRequestPage()),
            );
          },
          tooltip: "Add Request",
          child: const Icon(Icons.add),
        ),
      )
          : null, // Show FAB only if user is admin
    );
  }
}

// Card widget to display individual requests
class RequestCard extends StatelessWidget {
  final AssistanceRequest request;
  final bool isAdmin;

  const RequestCard({required this.request, required this.isAdmin, super.key});

  @override
  Widget build(BuildContext context) {
    String status = request.isCompleted == null
        ? 'Unknown'
        : (request.isCompleted! ? 'Completed' : 'Waiting');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(request.title),
        subtitle: Text("Status: $status\nWorkshop: ${request.workshopId}"),
        trailing: isAdmin
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Add code to navigate to edit request page if necessary
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Add code to delete the request if needed
              },
            ),
          ],
        )
            : null,
        onTap: () {
          // Add navigation to Request details page if needed
        },
      ),
    );
  }
}
