import 'dart:convert';
import '../utils/api_client.dart';
import '../models/workshop.dart';
import '../models/user.dart';

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
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> decodedList = json.decode(response.body); // Parse the JSON response as a list
      if (decodedList.isNotEmpty) {
        final Map<String, dynamic> workshopData = decodedList[0]; // Get the first element of the list
        return Workshop.fromJson(workshopData); // Use the first element to create a Workshop object
      } else {
        throw Exception('Workshop not found');
      }
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


  Future<String> deleteWorkshopById(String workshopId) async {
    final response = await apiClient.delete('/workshop/delete/id/$workshopId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body[0]);
      return decoded['message'];
    } else if (response.statusCode == 404) {
      throw Exception('Workshop not found');
    } else {
      throw Exception('Failed to delete workshop');
    }
  }

  Future<String> deleteWorkshopByName(String workshopName) async {
    final response = await apiClient.delete('/workshop/delete/name/$workshopName');

    if (response.statusCode == 200){
      final Map<String, dynamic> decoded = json.decode(response.body)[0];
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
      final Map<String, dynamic> decoded = json.decode(response.body)[0];
      return decoded['message'];
    } else if (response.statusCode == 404) {
      throw Exception('Workshop not found');
    } else {
      throw Exception('Failed to edit workshop');
    }
  }
  // Fetch workers for a specific workshop
  Future<List<Worker>> getWorkersForWorkshop(String workshopId) async {
    final response = await apiClient.get('/workshop/$workshopId/workers');

    if (response.statusCode == 200) {
      try {
        // Decode the response body
        final List<dynamic> decoded = json.decode(response.body);

        // The first element contains the worker data
        final List<dynamic> workersList = decoded[0];  // The data is in the first element of the array

        // Map the list to Worker objects
        return workersList.map((item) => Worker.fromJson(item)).toList();
      } catch (e) {
        print('Error parsing workers: $e');
        throw Exception('Failed to parse workers data');
      }
    } else if (response.statusCode == 404) {
      print("WORKERS NOT FOUND");
      throw Exception('Workers not found for the specified workshop');
    } else {
      throw Exception('Failed to load workers for the workshop');
    }
  }
}