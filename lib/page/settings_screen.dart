import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int focusMinutes = 25;
  int breakMinutes = 5;
  bool darkMode = false;
  bool soundNotification = true;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      focusMinutes = prefs.getInt('focusMinutes') ?? 25;
      breakMinutes = prefs.getInt('breakMinutes') ?? 5;
      darkMode = prefs.getBool('darkMode') ?? false;
      soundNotification = prefs.getBool('soundNotification') ?? true;
    });
  }

  Future<void> saveSettings() async {
    await prefs.setInt('focusMinutes', focusMinutes);
    await prefs.setInt('breakMinutes', breakMinutes);
    await prefs.setBool('darkMode', darkMode);
    await prefs.setBool('soundNotification', soundNotification);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved!')));
  }

  @override
  Widget build(BuildContext context) {
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
            value: focusMinutes.toDouble(),
            min: 10,
            max: 90,
            divisions: 16,
            label: "$focusMinutes min",
            onChanged: (value) {
              setState(() => focusMinutes = value.toInt());
            },
          ),
          const SizedBox(height: 20),
          const Text(
            "Break Time (minutes)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: breakMinutes.toDouble(),
            min: 3,
            max: 30,
            divisions: 9,
            label: "$breakMinutes min",
            onChanged: (value) {
              setState(() => breakMinutes = value.toInt());
            },
          ),
          const Divider(height: 40),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: darkMode,
            onChanged: (value) {
              setState(() => darkMode = value);
            },
          ),
          SwitchListTile(
            title: const Text("Sound Notification"),
            value: soundNotification,
            onChanged: (value) {
              setState(() => soundNotification = value);
            },
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: saveSettings,
            child: const Text("Save Settings"),
          ),
        ],
      ),
    );
  }
}
