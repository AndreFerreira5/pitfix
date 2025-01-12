import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pitfix_frontend/src/repository/user_repository.dart';
import 'package:provider/provider.dart';
import '../models/assistance_request.dart';
import '../repository/assistance_request_repository.dart';
import '../ui/edit_requests_worker.dart';

class WorkerRequests extends StatefulWidget {
  const WorkerRequests({super.key});

  @override
  _WorkerRequestsState createState() => _WorkerRequestsState();
}

class _WorkerRequestsState extends State<WorkerRequests> {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();
  late AssistanceRequestRepository _assistanceRequestRepository;
  late UserRepository _userRepository;
  late Future<List<String>?> userRequestsIds;
  late List<AssistanceRequest> _assistanceRequests = [];

  String? username;

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    _userRepository = Get.find<UserRepository>();
    initAsync();
  }

  // Fetch user data and assistance requests
  Future<void> initAsync() async {
    username = await _storage.read(key: "username");

    // Check if username is null or empty
    if (username == null || username!.isEmpty) {
      print("Error: Username is null or empty");
      return; // Handle error appropriately, maybe show an error message
    }

    // Get the user request IDs and handle the result asynchronously
    try {
      final userRequestIds = await _userRepository.getRequestsByUsername(username!);

      if (userRequestIds != null && userRequestIds.isNotEmpty) {
        // Now fetch the corresponding assistance requests for each ID
        List<Future<AssistanceRequest>> futures = [
          for (var requestId in userRequestIds)
            _assistanceRequestRepository.getAssistanceRequestById(requestId["_id"]),
        ];

        // Wait for all requests to be fetched
        List<AssistanceRequest> results = await Future.wait(futures);

        setState(() {
          _assistanceRequests = results; // Update the state with the fetched requests
        });
      } else {
        setState(() {
          _assistanceRequests = []; // If no requests, set it to empty
        });
      }
    } catch (e) {
      print("Error fetching user request IDs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _assistanceRequests.isEmpty
            ? const Center(
              child: Text(
                "You have no assistance requests.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
            : ListView.builder(
          itemCount: _assistanceRequests.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final request = _assistanceRequests[index];
            return RequestCard(
              request: request,
              onEdit: ()async{
                // Navigate to the edit screen with the selected request
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRequestsWorker(request: request),
                  ),
                );
                // After editing, reload the requests (you might want to optimize this)
                initAsync();
              },
            );
          },
        ),
    );
  }
}

// Card widget to display individual requests
class RequestCard extends StatelessWidget {
  final AssistanceRequest request;
  final VoidCallback onEdit;  // Added onEdit callback

  const RequestCard({
    required this.request,
    required this.onEdit,
    super.key});

  @override
  Widget build(BuildContext context) {
    String status = request.isCompleted == null
        ? 'Unknown'
        : (request.isCompleted! ? 'Completed' : 'Waiting');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(request.title),
        subtitle: Text("Status: $status"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton( //
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
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