import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/assistance_request.dart';
import '../repository/assistance_request_reepository.dart';
import 'request_details_page.dart';

class AdminRequestsPage extends StatefulWidget {
  const AdminRequestsPage({super.key});

  @override
  _AdminRequestsPageState createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  late AssistanceRequestRepository _assistanceRequestRepository;
  late Future<List<AssistanceRequest>> _assistanceRequestsFuture;

  @override
  void initState() {
    super.initState();
    print("Started");
    _assistanceRequestRepository = Get.find<AssistanceRequestRepository>();
    print(_assistanceRequestRepository.apiClient);
    _assistanceRequestsFuture = _assistanceRequestRepository.getAllAssistanceRequests();
    print(_assistanceRequestsFuture.isBlank);
    print("check");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Assistance Requests"),
      ),
      body: FutureBuilder<List<AssistanceRequest>>(
        future: _assistanceRequestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No requests available.'));
          }

          final requests = snapshot.data!;

          return ListView.builder(
            itemCount: requests.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final request = requests[index];
              return RequestCard(request: request);
            },
          );
        },
      ),
    );
  }

  // Card widget to display individual requests
  Widget RequestCard({required AssistanceRequest request}) {
    String status = request.isCompleted == null
        ? 'Unknown'
        : (request.isCompleted! ? 'Completed' : 'Waiting');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(request.title),
        subtitle: Text("Status: $status\nWorkshop: ${request.workshopId}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestDetailsPage(request: request),
                  ),
                );

                 */
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Exclui o pedido
                _deleteRequest(request.id!); // Supondo que o id não seja nulo
              },
            ),
          ],
        ),
        /*
        onTap: () {
          // Navega para a página de detalhes
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestDetailsPage(request: request),
            ),
          );
        },

         */
      ),
    );
  }

  // Método para excluir um pedido
  Future<void> _deleteRequest(String requestId) async {
    try {
      final result = await _assistanceRequestRepository.deleteAssistanceRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      setState(() {
        _assistanceRequestsFuture = _assistanceRequestRepository.getAllAssistanceRequests();  // Atualiza a lista
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete assistance request')),
      );
    }
  }
}
