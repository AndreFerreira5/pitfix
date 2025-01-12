import 'dart:convert';
import '../utils/api_client.dart';
import '../models/assistance_request.dart';

class AssistanceRequestRepository {
  final ApiClient apiClient;

  AssistanceRequestRepository({required this.apiClient});

  Future<List<AssistanceRequest>> getAllAssistanceRequests() async {
    final response = await apiClient.get('/assistance_request/all');

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      final List<dynamic> requestList = json.decode(decoded[0]['body']);
      return requestList.map((item) => AssistanceRequest.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load assistance requests');
    }
  }

  Future<AssistanceRequest> getAssistanceRequestById(String requestId) async {
    final response = await apiClient.get('/assistance_request/$requestId');

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      return AssistanceRequest.fromJson(decodedResponse[0]);
    } else if (response.statusCode == 404) {
      throw Exception('Assistance request not found');
    } else {
      throw Exception('Failed to load assistance request');
    }
  }

  Future<List<AssistanceRequest>> getRequestsByWorkshop(String workshopId) async {
    final response = await apiClient.get('/assistance_request/workshop/$workshopId');

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body)[0];
      return decoded.map((item) => AssistanceRequest.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('No assistance requests found for the specified workshop');
    } else {
      throw Exception('Failed to load assistance requests by workshop');
    }
  }

  Future<List<AssistanceRequest>> getRequestsByWorker(String workerId) async {
    final response = await apiClient.get('/assistance_request/worker/$workerId');

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      return decoded.map((item) => AssistanceRequest.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('No assistance requests found for the specified worker');
    } else {
      throw Exception('Failed to load assistance requests by worker');
    }
  }

  Future<String> createAssistanceRequest(AssistanceRequest assistanceRequest, String username) async {
    var requestJson = assistanceRequest.toJson();
    print(requestJson);
    final uri = Uri.parse('/assistance_request/add?username=$username');

    final response = await apiClient.post(uri.toString(), body: requestJson);
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      print("Decoded: $decoded");
      return decoded[0];
    } else {
      throw Exception('Failed to create assistance request');
    }
  }

  Future<String> editAssistanceRequest(String requestId, AssistanceRequest assistanceRequest) async {
    final response = await apiClient.put(
      '/assistance_request/edit/$requestId',
      body: json.encode(assistanceRequest.toJson()),
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      return decoded[0]['message'];
    } else if (response.statusCode == 404) {
      throw Exception('Assistance request not found');
    } else {
      throw Exception('Failed to edit assistance request');
    }
  }

  Future<String> deleteAssistanceRequest(String requestId, String username) async {
    print("boas1");
    final uri = Uri.parse('/assistance_request/delete/$requestId?username=$username');
    print(uri.toString());

    final response = await apiClient.delete(uri.toString());
    print("boas");

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body)[0];
      return decoded['message'];
    } else if (response.statusCode == 404) {
      throw Exception('Assistance request not found');
    } else {
      throw Exception('Failed to delete assistance request');
    }
  }


}
