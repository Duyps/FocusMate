import 'package:flashcard/page/settings_screen.dart';
import 'package:flashcard/page/timer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Duration selectedDuration = const Duration(minutes: 25);
  String selectedGoal = 'Study';
  bool skipBreak = false;
  int _currentIndex = 0;

  final List<String> goals = [
    'Study',
    'Work',
    'Relax',
    'Sport',
    'Entertainment',
    'Other',
  ];

  void _onStartPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          duration: selectedDuration,
          goal: selectedGoal,
          skipBreak: skipBreak,
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Time Tracker"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Select Duration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 150,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: selectedDuration,
                onTimerDurationChanged: (Duration newDuration) {
                  setState(() => selectedDuration = newDuration);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Goal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedGoal,
              isExpanded: true,
              items: goals
                  .map(
                    (goal) => DropdownMenuItem(value: goal, child: Text(goal)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedGoal = value);
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Skip Break", style: TextStyle(fontSize: 16)),
                const Spacer(),
                Switch(
                  value: skipBreak,
                  onChanged: (value) {
                    setState(() => skipBreak = value);
                  },
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _onStartPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Start", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
