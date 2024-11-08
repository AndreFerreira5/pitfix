import 'package:get/get.dart';
import '../utils/api_client.dart';
import '../repository/workshop_repository.dart';
import '../repository/user_repository.dart';

class RepositoryBinding extends Bindings {
  @override
  void dependencies() {
    final apiClient = ApiClient(baseUrl: "http://127.0.0.1:8000");

    // initialize and inject repositories
    Get.put<WorkshopRepository>(WorkshopRepository(apiClient: apiClient));
    Get.put<UserRepository>(UserRepository(apiClient: apiClient));
  }
}
