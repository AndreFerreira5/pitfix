import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pitfix_frontend/src/ui/add_request.dart';
import '../models/assistance_request.dart';
import '../repository/assistance_request_repository.dart';
import '../repository/workshop_repository.dart';
import '../ui/edit_requests_admin.dart';
import '../ui/request_details.dart';

class AdminRequests extends StatefulWidget {
  const AdminRequests({super.key});

  @override
  _AdminRequestsState createState() => _AdminRequestsState();
}

class _AdminRequestsState extends State<AdminRequests> {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();
  late AssistanceRequestRepository _assistanceRequestRepository;
  late WorkshopRepository _workshopRepository;

  late Future<List<AssistanceRequest>> _assistanceRequestsFuture;
  late Map<String, String> _workshopNames = {}; // Map for workshop ID to name

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    _workshopRepository = Get.find<WorkshopRepository>();
    _assistanceRequestsFuture = fetchRequests();
  }

  Future<List<AssistanceRequest>> fetchRequests() async {
    final requests = await _assistanceRequestRepository.getAllAssistanceRequests();
    await fetchWorkshopNames(requests);
    return requests;
  }

  Future<void> fetchWorkshopNames(List<AssistanceRequest> requests) async {
    Map<String, String> workshopNames = {};

    try {
      final workshopIds = requests
          .map((req) => req.workshopId)
          .where((id) => id != null)
          .toSet();

      for (var id in workshopIds) {
        if (id != null) {
          try {
            final workshop = await _workshopRepository.getWorkshopById(id);
            workshopNames[id] = workshop.name;
          } catch (e) {
            workshopNames[id] = "Unknown Workshop";
          }
        }
      }
    } catch (e) {
      print("Error fetching workshop names: $e");
    }

    setState(() {
      _workshopNames = workshopNames;
    });
  }

  Future<void> _deleteRequest(String requestId) async {
    final username = await _storage.read(key: "username");

    if (username == null || username.isEmpty) {
      print("Error: Username is null or empty");
      return;
    }

    try {
      await _assistanceRequestRepository.deleteAssistanceRequest(requestId, username);

      setState(() {
        _assistanceRequestsFuture = fetchRequests();
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
          return ListView.builder(
            itemCount: requests.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final request = requests[index];
              final workshopName = _workshopNames[request.workshopId] ?? 'Loading...';

              return RequestCard(
                request: request,
                workshopName: workshopName,
                onDelete: _deleteRequest,
                onEdit: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditRequestsAdmin(request: request),
                    ),
                  );
                  setState(() {
                    _assistanceRequestsFuture = fetchRequests();
                  });
                },
              );
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
      ),
    );
  }
}

// Updated RequestCard to display workshop name
class RequestCard extends StatelessWidget {
  final AssistanceRequest request;
  final String workshopName;
  final Function(String) onDelete;
  final VoidCallback onEdit;

  const RequestCard({
    required this.request,
    required this.workshopName,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String status = request.isCompleted == null
        ? 'Unknown'
        : (request.isCompleted! ? 'Completed' : 'Waiting');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(request.title),
        subtitle: Text("Status: $status\nWorkshop: $workshopName"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
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
                  onDelete(request.id!);
                }
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestDetails(
                request: request,
                workshopName: workshopName,
              ),
            ),
          );
        },
      ),
    );
  }
}
