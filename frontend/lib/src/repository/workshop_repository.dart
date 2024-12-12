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

  Future<Workshop> getWorkshopById(String workshopId) async {
    final response = await apiClient.get('/workshop/id/$workshopId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return Workshop.fromJson(json.decode(decoded[0]['body']));
    } else if (response.statusCode == 404) {
      throw Exception('Workshop not found');
    } else {
      throw Exception('Failed to load workshop');
    }
  }

  Future<Workshop> getWorkshopByName(String workshopName) async {
    final response = await apiClient.get('/workshop/name/$workshopName');

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return Workshop.fromJson(json.decode(decoded[0]['body']));
    } else if (response.statusCode == 404) {
      throw Exception('Workshop not found');
    } else {
      throw Exception('Failed to load workshop');
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


  Future<String> deleteWorkshop(String workshopId) async {
    final response = await apiClient.delete('/workshop/delete/$workshopId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return decoded['message'];
    } else if (response.statusCode == 404) {
      throw Exception('Workshop not found');
    } else {
      throw Exception('Failed to delete workshop');
    }
  }

  Future<String> editWorkshop(String workshopId, Workshop workshop) async {
    final response = await apiClient.put(
      '/workshop/edit/$workshopId',
      body: json.encode(workshop.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return decoded['message'];
    } else if (response.statusCode == 404) {
      throw Exception('Workshop not found');
    } else {
      throw Exception('Failed to edit workshop');
    }
  }
}