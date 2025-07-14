import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  int focusMinutes = 25;
  int breakMinutes = 5;
  bool darkMode = false;
  bool soundNotification = true;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    focusMinutes = prefs.getInt('focusMinutes') ?? 25;
    breakMinutes = prefs.getInt('breakMinutes') ?? 5;
    darkMode = prefs.getBool('darkMode') ?? false;
    soundNotification = prefs.getBool('soundNotification') ?? true;
    notifyListeners();
  }

  Future<void> updateFocusTime(int minutes) async {
    focusMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focusMinutes', minutes);
    notifyListeners();
  }

  Future<void> updateBreakTime(int minutes) async {
    breakMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('breakMinutes', minutes);
    notifyListeners();
  }

  Future<void> updateDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> updateSoundNotification(bool value) async {
    soundNotification = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundNotification', value);
    notifyListeners();
  }
}
