import 'package:get/get.dart';
import '../utils/api_client.dart';
import '../repository/workshop_repository.dart';
import '../repository/user_repository.dart';
import '../repository/auth_repository.dart';

class RepositoryBinding extends Bindings {
  @override
  void dependencies() {
    // change the url to localhost:8000 when in development
    //final apiClient = ApiClient(baseUrl: "https://pitfix.onrender.com");
    final apiClient = ApiClient(baseUrl: "http://localhost:8000");

    // initialize and inject repositories
    Get.put<WorkshopRepository>(WorkshopRepository(apiClient: apiClient));
    Get.put<UserRepository>(UserRepository(apiClient: apiClient));
    Get.put<AuthRepository>(AuthRepository(apiClient: apiClient));
  }
}
