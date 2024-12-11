import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pitfix_frontend/src/ui/add_request.dart'; // Assuming you have this page
import '../models/assistance_request.dart';
import '../repository/assistance_request_repository.dart'; // Assuming this repository exists

class AdminRequests extends StatefulWidget {
  const AdminRequests({super.key});

  @override
  _AdminRequestsState createState() => _AdminRequestsState();
}

class _AdminRequestsState extends State<AdminRequests> {
  late AssistanceRequestRepository _assistanceRequestRepository;
  late Future<List<AssistanceRequest>> _assistanceRequestsFuture;

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    _assistanceRequestsFuture = _assistanceRequestRepository.getAllAssistanceRequests();
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
              print(snapshot.error);
              return const Center(child: Text('No requests available.'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No requests available.'));
            }

            final requests = snapshot.data!;
            requests.forEach((request) {
              print('Workshop ID: ${request.workshopId}');
            });

            return ListView.builder(
              itemCount: requests.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final request = requests[index];
                return RequestCard(request: request);
              },
            );
          },
        ),
        floatingActionButton: Padding(
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
    );
  }
}

// Card widget to display individual requests
class RequestCard extends StatelessWidget {
  final AssistanceRequest request;

  const RequestCard({required this.request, super.key});

  @override
  Widget build(BuildContext context) {
    String status = request.isCompleted == null
        ? 'Unknown'
        : (request.isCompleted! ? 'Completed' : 'Waiting');

    // Use a fallback string if workshopId is null
    String workshopIdDisplay = request.workshopId ?? 'Unknown Workshop';


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(request.title),
        subtitle: Text("Status: $status\nWorkshop: $workshopIdDisplay"),
        trailing: Row(
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
        ),
        onTap: () {
          // Add navigation to Request details page if needed
        },
      ),
    );
  }
}