import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pitfix_frontend/src/repository/user_repository.dart';
import 'package:pitfix_frontend/src/ui/add_request.dart';
import 'package:provider/provider.dart';
import '../models/assistance_request.dart';
import '../repository/assistance_request_repository.dart';

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
            _assistanceRequestRepository.getAssistanceRequestById(requestId),
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

  // Function to delete a request
  Future<void> _deleteRequest(String requestId) async {
    username = await _storage.read(key: "username");

    // Check if username is null or empty
    if (username == null || username!.isEmpty) {
      print("Error: Username is null or empty");
      return; // Handle error appropriately, maybe show an error message
    }

    try {
      // Delete the request from the backend
      await _assistanceRequestRepository.deleteAssistanceRequest(requestId, username!);

      // After deletion, remove the request from the local list and update UI
      setState(() {
        _assistanceRequests.removeWhere((request) => request.id == requestId);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request deleted successfully')),
      );
    } catch (e) {
      print("Error: $e");
      // Show error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("All Assistance Requests"),
        ),
        body: _assistanceRequests.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _assistanceRequests.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final request = _assistanceRequests[index];
            return RequestCard(
              request: request,
              onDelete: _deleteRequest,
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
  final Function(String) onDelete;

  const RequestCard({required this.request, required this.onDelete, super.key});

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
              onPressed: () async {
                // Confirm deletion with a dialog
                bool? confirmDelete = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Request'),
                    content: const Text('Are you sure you want to delete this request?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmDelete == true) {
                  onDelete(request.id!); // Call the onDelete callback
                }
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