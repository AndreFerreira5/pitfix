import 'package:flutter/material.dart';
import '../models/assistance_request.dart';
import '../repository/assistance_request_repository.dart';
import 'package:get/get.dart';

class EditRequestsAdmin extends StatefulWidget {
  final AssistanceRequest request;

  const EditRequestsAdmin({super.key, required this.request});

  @override
  _EditRequestsAdminState createState() => _EditRequestsAdminState();
}

class _EditRequestsAdminState extends State<EditRequestsAdmin> {
  late AssistanceRequestRepository _assistanceRequestRepository;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool? _isCompleted;

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();

    _titleController = TextEditingController(text: widget.request.title);
    _descriptionController = TextEditingController(text: widget.request.description);
    _isCompleted = widget.request.isCompleted;
  }

  Future<void> _updateRequest() async {
    try {
      widget.request.title = _titleController.text;
      widget.request.description = _descriptionController.text;
      widget.request.isCompleted = _isCompleted;

      await _assistanceRequestRepository.editAssistanceRequest(
        widget.request.id!,
        widget.request,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request updated successfully.')),
      );
      Navigator.pop(context, true);
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
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:'),
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
                onPressed: _updateRequest,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
