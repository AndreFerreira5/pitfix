import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class SettingsPage extends StatelessWidget {
  final String role;

  const SettingsPage({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Change Option
            _buildSettingOption(
              icon: Icons.language,
              title: 'Change Language',
              onTap: () => _changeLanguageDialog(context),
            ),
            const SizedBox(height: 10),

            // Logout Option
            _buildSettingOption(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.redAccent,
              onTap: () {
                AuthController.to.logout();
              },
            ),

            // Spacer to push content to the top
            const Spacer(),

            // Version Information
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    Color color = Colors.blue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _changeLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage('assets/flags/us_flag.png'),
                ),
                title: const Text('English'),
                onTap: () {
                  _changeLanguage('en');
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage('assets/flags/pt_flag.png'),
                ),
                title: const Text('Portuguese'),
                onTap: () {
                  _changeLanguage('pt');
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage(String languageCode) {
    Get.updateLocale(Locale(languageCode));
    Get.snackbar(
      'Language Changed',
      languageCode == 'en'
          ? 'Language changed to English'
          : 'Idioma alterado para Português',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
