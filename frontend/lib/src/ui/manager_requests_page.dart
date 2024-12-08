import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/assistance_request.dart';  // Updated to AssistanceRequest
import 'add_request.dart';
import '../repository/assistance_request_reepository.dart';
import 'request_details_page.dart'; // Page where manager assigns a worker

class ManagerRequestsPage extends StatefulWidget {
  const ManagerRequestsPage({super.key});

  @override
  _ManagerRequestsPageState createState() => _ManagerRequestsPageState();
}

class _ManagerRequestsPageState extends State<ManagerRequestsPage> {
  late AssistanceRequestRepository _assistanceRequestRepository;
  late Future<List<AssistanceRequest>> _workshopRequestsFuture;
  String workshopId = "test_workshop";  // You would get this dynamically based on the logged-in manager

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    _workshopRequestsFuture = _assistanceRequestRepository.getRequestsByWorkshop(workshopId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workshop Assistance Requests"),
      ),
      body: FutureBuilder<List<AssistanceRequest>>(
        future: _workshopRequestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No requests available.'));
          }

          final requests = snapshot.data!;

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
    );
  }

  // Card widget to display individual requests
  Widget RequestCard({required AssistanceRequest request}) {
    // Safely handling the nullable 'isCompleted' value by using null-aware operator
    String status = request.isCompleted == null
        ? 'Unknown'  // Default status if 'isCompleted' is null
        : (request.isCompleted! ? 'Completed' : 'Waiting');

    // Format the date
    String formattedDate = "${request.creationDate.day}/${request.creationDate.month}/${request.creationDate.year}";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(request.title),
        subtitle: Text("Status: $status"),
        /*
        onTap: () {
          // Navigate to the request details page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestDetailsPage(request: request),
            ),
          );
        },*/
      ),
    );
  }
}
