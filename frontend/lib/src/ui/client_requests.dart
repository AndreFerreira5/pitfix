import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pitfix_frontend/src/repository/user_repository.dart';
import 'package:pitfix_frontend/src/repository/workshop_repository.dart';
import 'package:pitfix_frontend/src/ui/add_request.dart';
import 'package:provider/provider.dart';
import '../models/assistance_request.dart';
import '../repository/assistance_request_repository.dart';
import '../ui/request_details.dart';

class ClientRequests extends StatefulWidget {
  const ClientRequests({super.key});

  @override
  _ClientRequestsState createState() => _ClientRequestsState();
}

class _ClientRequestsState extends State<ClientRequests> {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();
  late AssistanceRequestRepository _assistanceRequestRepository;
  late UserRepository _userRepository;
  late WorkshopRepository _workshopRepository;

  late List<AssistanceRequest> _assistanceRequests = [];
  late Map<String, String> _workshopNames = {}; // Map for workshop ID to name

  String? username;

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    _userRepository = Get.find<UserRepository>();
    _workshopRepository = Get.find<WorkshopRepository>();
    initAsync();
  }

  // Fetch user data and assistance requests
  Future<void> initAsync() async {
    username = await _storage.read(key: "username");

    if (username == null || username!.isEmpty) {
      print("Error: Username is null or empty");
      return;
    }

    try {
      final userRequestIds = await _userRepository.getUserRequestsIds(username!);

      if (userRequestIds != null && userRequestIds.isNotEmpty) {
        // Fetch requests for each ID
        List<Future<AssistanceRequest>> requestFutures = userRequestIds.map((id) {
          return _assistanceRequestRepository.getAssistanceRequestById(id);
        }).toList();

        final requests = await Future.wait(requestFutures);
        setState(() {
          _assistanceRequests = requests;
        });

        // Fetch workshop names
        await fetchWorkshopNames(requests);
      } else {
        setState(() {
          _assistanceRequests = [];
        });
      }
    } catch (e) {
      print("Error fetching client requests: $e");
    }
  }

  Future<void> fetchWorkshopNames(List<AssistanceRequest> requests) async {
    Map<String, String> workshopNames = {};

    try {
      // Collect unique workshop IDs
      final workshopIds = requests
          .map((req) => req.workshopId)
          .where((id) => id != null)
          .toSet();

      // Fetch workshop details for each ID
      for (var id in workshopIds) {
        if (id != null) {
          try {
            final workshop = await _workshopRepository.getWorkshopById(id);
            workshopNames[id] = workshop.name;
          } catch (e) {
            workshopNames[id] = "Unknown Workshop"; // Handle missing workshops
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
          final workshopName = _workshopNames[request.workshopId] ?? 'Loading...';

          return RequestCard(
            request: request,
            workshopName: workshopName,
          );
        },
      ),
    );
  }
}

// Updated RequestCard to display workshop name
class RequestCard extends StatelessWidget {
  final AssistanceRequest request;
  final String workshopName;

  const RequestCard({
    required this.request,
    required this.workshopName,
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
