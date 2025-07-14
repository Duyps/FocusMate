import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Focus Time (minutes)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: settings.focusMinutes.toDouble(),
            min: 10,
            max: 90,
            divisions: 16,
            label: "${settings.focusMinutes} min",
            onChanged: (value) {
              settings.updateFocusTime(value.toInt());
            },
          ),
          const SizedBox(height: 20),
          const Text(
            "Break Timeê (minutes)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: settings.breakMinutes.toDouble(),
            min: 3,
            max: 30,
            divisions: 9,
            label: "${settings.breakMinutes} min",
            onChanged: (value) {
              settings.updateBreakTime(value.toInt());
            },
          ),
          const Divider(height: 40),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: settings.darkMode,
            onChanged: (value) {
              settings.updateDarkMode(value);
            },
          ),
          SwitchListTile(
            title: const Text("Sound Notification"),
            value: settings.soundNotification,
            onChanged: (value) {
              settings.updateSoundNotification(value);
            },
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text("Settings Saved"),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Settings saved!')));
            },
          ),
        ],
      ),
    );
  }
}
