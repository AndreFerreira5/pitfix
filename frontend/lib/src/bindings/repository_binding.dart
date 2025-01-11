import 'package:get/get.dart';
import 'package:pitfix_frontend/src/repository/assistance_request_repository.dart';
import '../utils/api_client.dart';
import '../repository/workshop_repository.dart';
import '../repository/user_repository.dart';
import '../repository/auth_repository.dart';

class RepositoryBinding extends Bindings {
  @override
  void dependencies() {
    // change the url to localhost when in development
    //final apiClient = ApiClient(baseUrl: "https://pitfix.onrender.com");
    //final apiClient = ApiClient(baseUrl: "http://localhost:8000");
    final apiClient = ApiClient(baseUrl: "http://100.64.195.51:6969");

    // initialize and inject repositories
    Get.put<WorkshopRepository>(WorkshopRepository(apiClient: apiClient));
    Get.put<UserRepository>(UserRepository(apiClient: apiClient));
    Get.put<AuthRepository>(AuthRepository(apiClient: apiClient));
    Get.put<AssistanceRequestRepository>(AssistanceRequestRepository(apiClient: apiClient));
  }
}
