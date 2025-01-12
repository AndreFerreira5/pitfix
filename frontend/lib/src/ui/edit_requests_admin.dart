import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/assistance_request.dart';
import '../repository/assistance_request_repository.dart';

class EditRequestsAdmin extends StatefulWidget {
  final AssistanceRequest request;

  const EditRequestsAdmin({Key? key, required this.request}) : super(key: key);

  @override
  _EditRequestsAdmin createState() => _EditRequestsAdmin();
}

class _EditRequestsAdmin extends State<EditRequestsAdmin> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _workshopIdController;
  late TextEditingController _workersIdsController;
  bool? _isCompleted;

  late AssistanceRequestRepository _assistanceRequestRepository;

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();

    _titleController = TextEditingController(text: widget.request.title);
    _descriptionController = TextEditingController(text: widget.request.description);
    _workshopIdController = TextEditingController(text: widget.request.workshopId);
    _workersIdsController = TextEditingController(text: widget.request.workersIds.join(", "));
    _isCompleted = widget.request.isCompleted;
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedRequest = AssistanceRequest(
          id: widget.request.id,
          title: _titleController.text,
          description: _descriptionController.text,
          workshopId: _workshopIdController.text,
          workersIds: _workersIdsController.text.split(", ").map((id) => id.trim()).toList(),
          isCompleted: _isCompleted,
          creationDate: widget.request.creationDate,
        );

        await _assistanceRequestRepository.editAssistanceRequest(widget.request.id!, updatedRequest);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request updated successfully')),
        );

        Navigator.pop(context, updatedRequest);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workshopIdController,
                decoration: const InputDecoration(labelText: 'Workshop ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a workshop ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workersIdsController,
                decoration: const InputDecoration(
                  labelText: 'Worker IDs',
                  hintText: 'Separate IDs with commas',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Completed'),
                value: _isCompleted ?? false,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
