import 'package:flutter/material.dart';
import '../models/assistance_request.dart';
import '../repository/assistance_request_repository.dart';
import 'package:get/get.dart';

class EditRequestsWorker extends StatefulWidget {
  final AssistanceRequest request;

  const EditRequestsWorker({super.key, required this.request});

  @override
  _EditRequestsWorkerState createState() => _EditRequestsWorkerState();
}

class _EditRequestsWorkerState extends State<EditRequestsWorker> {
  late AssistanceRequestRepository _assistanceRequestRepository;
  bool? _isCompleted;

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    _isCompleted = widget.request.isCompleted;
  }

  Future<void> _updateRequestStatus() async {
    try {
      widget.request.isCompleted = _isCompleted;
      await _assistanceRequestRepository.editAssistanceRequest(
        widget.request.id!,
        widget.request,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request updated successfully.')),
      );
      Navigator.pop(context, true); // Pass success response back
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Request: ${widget.request.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.request.description ?? 'No description provided.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DropdownButton<bool>(
                  value: _isCompleted,
                  items: const [
                    DropdownMenuItem(
                      value: false,
                      child: Text('Waiting'),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateRequestStatus,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}