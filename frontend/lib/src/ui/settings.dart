import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'workshops.dart';

class SettingsPage extends StatefulWidget {
  final String role; // Add role as a parameter to the SettingsPage

  const SettingsPage({super.key, required this.role});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Default radial distance value (in kilometers)
  double _radialDistance = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Conditionally render the Radial Distance Slider for only the client role
              if (widget.role == 'client')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Max Distance to Workshops (in km)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _radialDistance,
                      min: 1.0,
                      max: 100.0,
                      divisions: 99,
                      label: '${_radialDistance.toStringAsFixed(1)} km',
                      onChanged: (value) {
                        setState(() {
                          _radialDistance = value;
                        });
                      },
                    ),
                    Text(
                      'Selected distance: ${_radialDistance.toStringAsFixed(1)} km',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Language Selection Button (always visible)
              ElevatedButton(
                onPressed: () {
                  _changeLanguageDialog();
                },
                child: const Text('Change Language'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show language selection dialog
  void _changeLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  _changeLanguage('en');
                },
              ),
              ListTile(
                title: const Text('Spanish'),
                onTap: () {
                  _changeLanguage('es');
                },
              ),
              ListTile(
                title: const Text('French'),
                onTap: () {
                  _changeLanguage('fr');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to change language
  void _changeLanguage(String languageCode) {
    Get.updateLocale(Locale(languageCode));
    Navigator.pop(context); // Close the dialog
  }
}