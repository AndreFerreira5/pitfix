import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pitfix_frontend/src/repository/assistance_request_repository.dart';
import 'package:pitfix_frontend/src/repository/user_repository.dart';
import 'package:pitfix_frontend/src/models/assistance_request.dart';
import 'package:pitfix_frontend/src/models/user.dart';
import 'package:pitfix_frontend/src/repository/workshop_repository.dart';

class EditRequestScreen extends StatefulWidget {
  final AssistanceRequest request;

  const EditRequestScreen({Key? key, required this.request}) : super(key: key);

  @override
  _EditRequestScreenState createState() => _EditRequestScreenState();
}

class _EditRequestScreenState extends State<EditRequestScreen> {
  late AssistanceRequestRepository _assistanceRequestRepository;
  late WorkshopRepository _workshopRepository;
  List<User> _workers = [];
  List<String> _selectedWorkerIds = [];
  List<User> _assignedWorkers = []; // List to store assigned workers

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    _workshopRepository = Get.find<WorkshopRepository>();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch workers for the current workshop
      final workshopId = widget.request.workshopId;
      final workers = await _workshopRepository.getWorkersForWorkshop(workshopId);
      setState(() {
        _workers = workers;
        _assignedWorkers = _workers.where((worker) => widget.request.workersIds.contains(worker.id)).toList(); // Get the assigned workers
        _selectedWorkerIds = List.from(widget.request.workersIds); // Set initially selected workers
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        print("(ERROR)1-Failed to load workers: $e");
        _errorMessage = "Failed to load workers: $e";
        _isLoading = false;
      });
    }
  }

  // Method to update the request
  Future<void> _updateRequest() async {
    try {
      // Ensure that workersIds is initialized correctly
      widget.request.workersIds
        ..clear()
        ..addAll(_selectedWorkerIds);

      await _assistanceRequestRepository.editAssistanceRequest(
        widget.request.id!,
        widget.request,
      );
      Navigator.pop(context); // Go back after saving
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workers assigned successfully')),
      );
    } catch (e) {
      print("(ERROR)2-Failed to load workers: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign workers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Workers'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Assign workers to request: ${widget.request.title}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // Section to display assigned workers
          if (_assignedWorkers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Currently Assigned Workers:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: _assignedWorkers.map((worker) {
                  return ListTile(
                    title: Text(worker.username),
                    subtitle: Text(worker.role ?? 'No role'),
                  );
                }).toList(),
              ),
            ),
          ],
          // List of available workers
          Expanded(
            child: ListView.builder(
              itemCount: _workers.length,
              itemBuilder: (context, index) {
                final worker = _workers[index];
                return CheckboxListTile(
                  title: Text(worker.username),
                  subtitle: Text(worker.role ?? 'No role'),
                  value: _selectedWorkerIds.contains(worker.id),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        _selectedWorkerIds.add(worker.id!);
                      } else {
                        _selectedWorkerIds.remove(worker.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _updateRequest,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}


