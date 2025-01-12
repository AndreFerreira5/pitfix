import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../models/assistance_request.dart';
import '../repository/assistance_request_repository.dart';  // AssistanceRequestRepository
import '../repository/workshop_repository.dart';  // WorkshopRepository
import '../models/workshop.dart';  // Workshop model

class AddRequestPage extends StatefulWidget {
  final String? preselectedWorkshop;

  const AddRequestPage({Key? key, this.preselectedWorkshop}) : super(key: key);

  @override
  _AddRequestPageState createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();
  String? username;

  String? _selectedWorkshop;
  bool _isCompleted = false;
  DateTime _creationDate = DateTime.now();
  List<String> _workersIds = [];

  late AssistanceRequestRepository _assistanceRequestRepository;
  late WorkshopRepository _workshopRepository;
  late Future<List<Workshop>> _workshopsFuture;

  @override
  void initState() {
    super.initState();
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    _workshopRepository = Get.find<WorkshopRepository>();
    _workshopsFuture = _workshopRepository.getAllWorkshops(); // Fetch all workshops
    _selectedWorkshop = widget.preselectedWorkshop;
    _getUsername();
  }

  Future<void> _getUsername() async {
    username = await _storage.read(key: 'username');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assistance Request"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Add New Request",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              // Title Field
              _buildRoundedTextField(
                controller: _titleController,
                label: "Title",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              _buildRoundedTextField(
                controller: _descriptionController,
                label: "Description",
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Workshop Dropdown
              _buildWorkshopDropdown(),
              const SizedBox(height: 16),

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
                  "Add Request",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields with rounded corners
  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  // Workshop Dropdown
  Widget _buildWorkshopDropdown() {
    return FutureBuilder<List<Workshop>>(
      future: _workshopsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching workshops'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No workshops available'));
        }

        final workshops = snapshot.data!;

        return DropdownButtonFormField<String>(
          value: _selectedWorkshop,
          decoration: const InputDecoration(
            labelText: "Select Workshop",
            border: OutlineInputBorder(),
          ),
          items: workshops.map((workshop) {
            return DropdownMenuItem<String>(
              value: workshop.id,
              child: Text(workshop.name), // Display the workshop's name
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedWorkshop = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a workshop';
            }
            return null;
          },
        );
      },
    );
  }


  // Method to submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (username == null || username!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username is not available')),
        );
        return;
      }

      final newRequest = AssistanceRequest(
        title: _titleController.text,
        description: _descriptionController.text,
        workshopId: _selectedWorkshop ?? "",
        workersIds: _workersIds,
        isCompleted: _isCompleted,
        creationDate: _creationDate,
      );

      try {
        final result = await _assistanceRequestRepository.createAssistanceRequest(newRequest, username!);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
        Navigator.pop(context); // Go back to the previous page
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create assistance request')),
        );
      }
    }
  }
}