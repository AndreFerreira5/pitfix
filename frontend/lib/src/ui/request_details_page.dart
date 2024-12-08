/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/assistance_request.dart';  // Importing the AssistanceRequest model
import '../repository/assistance_request_reepository.dart';  // Importing the AssistanceRequestRepository

class RequestDetailsPage extends StatefulWidget {
  final AssistanceRequest request;

  const RequestDetailsPage({required this.request, super.key});

  @override
  _RequestDetailsPageState createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  final AssistanceRequestRepository _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
  final _formKey = GlobalKey<FormState>();
  String? _selectedWorkerId;

  @override
  void initState() {
    super.initState();
    _selectedWorkerId = widget.request.workersIds.isNotEmpty ? widget.request.workersIds.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              Text(
                "Title: ${widget.request.title}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                "Description: ${widget.request.description}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Status
              Text(
                "Status: ${widget.request.isCompleted == null ? 'Unknown' : widget.request.isCompleted! ? 'Completed' : 'Waiting'}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Workshop
              Text(
                "Workshop: ${widget.request.workshopId}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Workers
              Text(
                "Assigned Workers: ${widget.request.workersIds.join(', ')}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Worker selection for assignment
              DropdownButtonFormField<String>(
                value: _selectedWorkerId,
                decoration: const InputDecoration(
                  labelText: "Assign Worker",
                  border: OutlineInputBorder(),
                ),
                items: [
                  'worker1', 'worker2', 'worker3'  // Example workers, replace with actual workers list
                ].map((workerId) {
                  return DropdownMenuItem<String>(
                    value: workerId,
                    child: Text(workerId),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWorkerId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a worker';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Assign Worker & Update Request",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to submit the form and update the request
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Create a copy of the original request and update it with the assigned worker
      final updatedRequest = widget.request.copyWith(
        workersIds: [...widget.request.workersIds, _selectedWorkerId!],  // Add the new worker
        isCompleted: widget.request.isCompleted ?? false,  // Keep the current status
      );

      try {
        final result = await _assistanceRequestRepository.editAssistanceRequest(widget.request.id!, updatedRequest);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
        Navigator.pop(context, true);  // Go back to the previous page after the update
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update assistance request')),
        );
      }
    }
  }
}


 */