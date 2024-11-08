import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'workshops.dart';

class NavigationMenu extends StatelessWidget {
  final String userRole; // hold the user role
  final NavigationController navController = Get.put(NavigationController()); // instantiate the controller

  NavigationMenu({super.key, required this.userRole});

  // Define pages based on user role
  List<Widget> _getPages(String role) {
    switch (role) {
      case 'admin':
        return [
          Workshops(),
          Center(child: Text('Requests Page')),
          Center(child: Text('Profile Page')),
          Center(child: Text('Settings Page')),
        ];
      case 'manager':
        return [
          Center(child: Text('My Workshop Page')),
          Center(child: Text('Profile Page')),
          Center(child: Text('Settings Page')),
        ];
      case 'worker':
        return [
          Center(child: Text('Requests Page')),
          Center(child: Text('Profile Page')),
          Center(child: Text('Settings Page')),
        ];
      case 'client':
        return [
          Center(child: Text('Workshops Page')),
          Center(child: Text('My Requests Page')),
          Center(child: Text('Profile Page')),
          Center(child: Text('Settings Page')),
        ];
      default:
        return [Center(child: Text('No content available'))];
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

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(userRole); // Get pages based on role
    final destinations = _getDestinations(userRole); // Get destinations based on role

    return Scaffold(
      body: Stack(
        children: [
          // Reactive page content based on selected index
          Obx(() => Positioned.fill(
            child: pages[navController.selectedIndex.value],
          )),
          // Floating Navigation Bar
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
                child: Obx(() => NavigationBar( // Wrap NavigationBar in Obx to reactively update
                  destinations: destinations,
                  height: 60,
                  selectedIndex: navController.selectedIndex.value, // Bind to controller
                  onDestinationSelected: navController.changePage, // Update index on tap
                )),
              ),
            ),
          ),
        ],
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