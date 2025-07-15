import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your Settings",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Focus Time (minutes)",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.white30,
                  value: settings.focusMinutes.toDouble(),
                  min: 10,
                  max: 90,
                  divisions: 16,
                  label: "${settings.focusMinutes} min",
                  onChanged: (value) {
                    settings.updateFocusTime(value.toInt());
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  "Break Time (minutes)",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  activeColor: Colors.greenAccent,
                  inactiveColor: Colors.white30,
                  value: settings.breakMinutes.toDouble(),
                  min: 3,
                  max: 30,
                  divisions: 9,
                  label: "${settings.breakMinutes} min",
                  onChanged: (value) {
                    settings.updateBreakTime(value.toInt());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    "Sound Notification",
                    style: TextStyle(color: Colors.white),
                  ),
                  secondary: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                  ),
                  value: settings.soundNotification,
                  onChanged: (value) {
                    settings.updateSoundNotification(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Save Settings"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text("Log out"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 235, 88, 77),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
