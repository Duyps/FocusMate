import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flashcard/page/timer_screen.dart';

class HomeTabContent extends StatefulWidget {
  const HomeTabContent({super.key});

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  Duration _selectedDuration = const Duration(minutes: 25);
  String _selectedGoal = 'Study';
  bool _skipBreak = false;

  final Map<String, Color> goalColors = {
    'Study': const Color.fromARGB(255, 94, 160, 215),
    'Work': const Color.fromARGB(255, 101, 195, 104),
    'Relax': const Color.fromARGB(255, 255, 186, 81),
    'Sport': const Color.fromARGB(255, 255, 117, 107),
    'Entertainment': const Color.fromARGB(255, 169, 95, 183),
    'Other': Colors.grey,
  };

  Widget _buildGoalSelector() {
    final goals = goalColors.keys.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Goal",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: goals.map((goal) {
                final isSelected = goal == _selectedGoal;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: goalColors[goal],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(goal),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedGoal = goal),
                    selectedColor: goalColors[goal]?.withOpacity(0.25),
                    backgroundColor: Colors.grey[850],
                    labelStyle: TextStyle(
                      color: isSelected ? goalColors[goal] : Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Focus Duration",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: CupertinoTheme(
              data: const CupertinoThemeData(brightness: Brightness.dark),
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: _selectedDuration,
                onTimerDurationChanged: (value) =>
                    setState(() => _selectedDuration = value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildGoalSelector(),
          const SizedBox(height: 20),
          _buildTimePicker(),
          const SizedBox(height: 10),
          SwitchListTile.adaptive(
            value: _skipBreak,
            onChanged: (val) => setState(() => _skipBreak = val),
            title: const Text(
              "Skip break time",
              style: TextStyle(color: Colors.white),
            ),
            activeColor: Colors.greenAccent,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TimerScreen(
                    duration: _selectedDuration,
                    goal: _selectedGoal,
                    skipBreak: _skipBreak,
                    focusTime: const Duration(minutes: 25),
                    breakTime: const Duration(minutes: 5),
                    goalColor: goalColors[_selectedGoal] ?? Colors.blue,
                  ),
                ),
              );
            },
            child: const Text("Start", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
