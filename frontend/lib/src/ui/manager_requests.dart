import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pitfix_frontend/src/repository/user_repository.dart';
import 'package:pitfix_frontend/src/repository/assistance_request_repository.dart';
import 'package:pitfix_frontend/src/models/assistance_request.dart';
import 'package:provider/provider.dart';
import '../ui/edit_request.dart';

class ManagerRequests extends StatefulWidget {
  const ManagerRequests({super.key});

  @override
  _ManagerRequestsState createState() => _ManagerRequestsState();
}

class _ManagerRequestsState extends State<ManagerRequests> {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();
  late AssistanceRequestRepository _assistanceRequestRepository;
  late UserRepository _userRepository;
  late List<AssistanceRequest> _assistanceRequests = [];

  String? username;
  String? workshopId;

  // State variables for loading and error handling
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    _userRepository = Get.find<UserRepository>();
    initAsync();
  }

  // Fetch manager data and the assistance requests of their workshop
  Future<void> initAsync() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset the error message on a new load
    });

    username = await _storage.read(key: "username");

    // Ensure that username is not null or empty
    if (username == null || username!.isEmpty) {
      print("Error: Username is null or empty");
      setState(() {
        _errorMessage = "Error: Username is null or empty";
        _isLoading = false;
      });
      return;
    }

    try {
      // First, fetch the manager's workshop ID
      final fetchedWorkshopId = await _userRepository.getManagerWorkshopId(username!);
      print("manager workshopID: $fetchedWorkshopId");

      if (fetchedWorkshopId == null || fetchedWorkshopId.isEmpty) {
        print("Error: Manager does not have an associated workshop.");
        setState(() {
          _errorMessage = "Error: Manager does not have an associated workshop.";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        workshopId = fetchedWorkshopId;
      });

      // Once we have the workshop ID, fetch the requests for that workshop
      if (workshopId != null) {
        print("workshopId: $workshopId");
        final requests = await _assistanceRequestRepository.getRequestsByWorkshop(workshopId!);


        setState(() {
          _assistanceRequests = requests; // Update the UI with the fetched requests
          _isLoading = false; // Data is loaded, stop the loading indicator
        });
      } else {
        setState(() {
          _assistanceRequests = [];
        });
      }
    } catch (e) {
      print("Error fetching manager requests: $e");
      _isLoading = false;
      _errorMessage = "Error fetching manager requests: $e";
    }
  }


  // Function to delete a request
  Future<void> _deleteRequest(String requestId) async {
    try {
      await _assistanceRequestRepository.deleteAssistanceRequest(requestId, username!);

      setState(() {
        _assistanceRequests.removeWhere((request) => request.id == requestId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request deleted successfully')),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workshop Requests"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!)) // Display error message if exists
          : ListView.builder(
        itemCount: _assistanceRequests.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final request = _assistanceRequests[index];
          return RequestCard(
            request: request,
            onDelete: _deleteRequest,
            onEdit: () async {
              // Navigate to the edit screen with the selected request
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditRequestScreen(request: request),
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

// Card widget to display individual requests with an edit button
class RequestCard extends StatelessWidget {
  final AssistanceRequest request;
  final Function(String) onDelete;
  final VoidCallback onEdit;  // Added onEdit callback

  const RequestCard({
    required this.request,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String status = request.isCompleted == null
        ? 'Unknown'
        : (request.isCompleted! ? 'Completed' : 'Waiting');

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
              icon: const Icon(Icons.delete),
              onPressed: () async {
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
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,  // Trigger the edit action
            ),
          ],
        ),
      ),
    );
  }
}
