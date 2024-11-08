import 'dart:convert';
import '../utils/api_client.dart';
import '../models/workshop.dart';

class WorkshopRepository {
  final ApiClient apiClient;

  WorkshopRepository({required this.apiClient});

  Future<List<Workshop>> getAllWorkshops() async {
    final response = await apiClient.get('/workshop/all');

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      final List<dynamic> workshopList = json.decode(decoded[0]['body']);
      return workshopList.map((item) => Workshop.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load workshops');
    }
  }

  Future<String?> addWorkshop(Workshop workshop) async {
    var workshopJson = workshop.toJson();

    // send the filtered body in the request
    final response = await apiClient.post('/workshop/add', body: workshopJson);

    if (response.statusCode == 200) {
      print(response.body);
      return response.body;
    }
    return null;
  }
}