import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:pitfix_frontend/src/ui/admin_requests.dart';
import 'package:pitfix_frontend/src/ui/manager_requests.dart';
import 'package:pitfix_frontend/src/ui/profile.dart';
import 'package:pitfix_frontend/src/ui/settings.dart';
import 'package:pitfix_frontend/src/ui/worker_requests.dart';
import 'client_requests.dart';
import 'workshops.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  final NavigationController navController = Get.put(NavigationController());
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();
  final AuthController authController = Get.find<AuthController>();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    String? role = await _storage.read(key: 'user_role');
    setState(() {
      userRole = role;
    });
  }

  // Define pages based on user role
  List<Widget> _getPages(String role) {
    switch (role) {
      case 'admin':
        return [
          Workshops(userRole: role),
          const AdminRequests(),
          const ProfilePage(),
          SettingsPage(role: role),
        ];
      case 'manager':
        return [
          const ManagerRequests(),
          const ProfilePage(),
          SettingsPage(role: role),
        ];
      case 'worker':
        return [
          const WorkerRequests(),
          const ProfilePage(),
          SettingsPage(role: role),
        ];
      case 'client':
        return [
          Workshops(userRole: role),
          const ClientRequests(),
          const ProfilePage(),
          SettingsPage(role: role),
        ];
      default:
        return [const Center(child: Text('No content available'))];
    }
  }

  // Define destinations based on user role
  List<NavigationDestination> _getDestinations(String role) {
    switch (role) {
      case 'admin':
        return const [
          NavigationDestination(icon: Icon(Iconsax.shop), label: 'Workshops'),
          NavigationDestination(icon: Icon(Iconsax.messages_2), label: 'Requests'),
          NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          NavigationDestination(icon: Icon(Iconsax.setting_2), label: 'Settings'),
        ];
      case 'manager':
        return const [
          NavigationDestination(icon: Icon(Iconsax.shop), label: 'My Workshop'),
          NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          NavigationDestination(icon: Icon(Iconsax.setting_2), label: 'Settings'),
        ];
      case 'worker':
        return const [
          NavigationDestination(icon: Icon(Iconsax.messages_2), label: 'Requests'),
          NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          NavigationDestination(icon: Icon(Iconsax.setting_2), label: 'Settings'),
        ];
      case 'client':
        return const [
          NavigationDestination(icon: Icon(Iconsax.shop), label: 'Workshops'),
          NavigationDestination(icon: Icon(Iconsax.messages_2), label: 'My Requests'),
          NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          NavigationDestination(icon: Icon(Iconsax.setting_2), label: 'Settings'),
        ];
      default:
        return const [];
    }
  }

  // Define titles for the pages
  List<String> _getTitles(String role) {
    switch (role) {
      case 'admin':
        return ['PitFix - Workshops', 'PitFix - Requests', 'PitFix - Profile', 'PitFix - Settings'];
      case 'manager':
        return ['PitFix - My Workshop', 'PitFix - Profile', 'PitFix - Settings'];
      case 'worker':
        return ['PitFix - Requests', 'PitFix - Profile', 'PitFix - Settings'];
      case 'client':
        return ['PitFix - Workshops', 'PitFix - My Requests', 'PitFix - Profile', 'PitFix - Settings'];
      default:
        return ['PitFix'];
    }
  }

  @override
  Widget build(BuildContext context) {
    userRole = AuthController.to.userRole.value;

    if (userRole == null || userRole == "") {
      AuthController.to.logout("Error", "Couldn't get the user role");
    }

    final pages = _getPages(userRole!); // get pages based on role
    final destinations = _getDestinations(userRole!); // get destinations based on role
    final titles = _getTitles(userRole!); // get titles based on role

    return Scaffold(
      body: Stack(
        children: [
          // Reactive page content based on selected index
          Obx(() => Positioned.fill(
            child: pages[navController.selectedIndex.value],
          )),
          // Floating navigation bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Obx(() => NavigationBar(
                  destinations: destinations,
                  height: 60,
                  selectedIndex: navController.selectedIndex.value,
                  onDestinationSelected: navController.changePage,
                )),
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        title: Obx(() {
          final titleParts = titles[navController.selectedIndex.value].split(' - ');
          return RichText(
            text: TextSpan(
              style: Theme.of(context)
                  .appBarTheme
                  .titleTextStyle
                  ?.copyWith(color: Colors.white) ??
                  const TextStyle(fontSize: 20, color: Colors.blue),
              children: [
                TextSpan(
                  text: titleParts[0], // "PitFix"
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (titleParts.length > 1)
                  TextSpan(
                    text: ' - ${titleParts[1]}', // The rest of the title
                  ),
              ],
            ),
          );
        }),
      ),

    );
  }
}

class NavigationController extends GetxController {
  // Observable for the selected index
  var selectedIndex = 0.obs;

  // Method to update the selected index
  void changePage(int index) {
    selectedIndex.value = index;
  }
}
