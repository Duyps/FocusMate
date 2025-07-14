import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flashcard/page/stats_screen.dart';
import 'package:flashcard/page/settings_screen.dart';
import 'timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Duration _selectedDuration = const Duration(minutes: 25);
  String _selectedGoal = 'Study';
  bool _skipBreak = false;
  final Map<String, Color> goalColors = {
    'Study': Colors.blue,
    'Work': Colors.green,
    'Relax': Colors.orange,
    'Sport': Colors.red,
    'Entertainment': Colors.purple,
    'Other': Colors.grey,
  };

  /*final List<Map<String, dynamic>> _presets = [
    {'goal': 'Study', 'duration': const Duration(minutes: 90)},
    {'goal': 'Work', 'duration': const Duration(minutes: 60)},
    {'goal': 'Relax', 'duration': const Duration(minutes: 30)},
  ];
  void _addPreset(String goal, Duration duration) {
    setState(() {
      _presets.add({'goal': goal, 'duration': duration});
    });
  }

  void _removePreset(int index) {
    setState(() {
      _presets.removeAt(index);
    });
  }

  void _showAddPresetDialog() {
    String selectedGoal = _selectedGoal;
    Duration selectedDuration = const Duration(minutes: 25);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Add Preset"),
            content: SizedBox(
              height: 250, // ⚠️ Cố định chiều cao tránh lỗi intrinsic
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: selectedGoal,
                    items:
                        [
                          'Study',
                          'Work',
                          'Relax',
                          'Sport',
                          'Entertainment',
                          'Other',
                        ].map((goal) {
                          return DropdownMenuItem(
                            value: goal,
                            child: Text(goal),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedGoal = value);
                      }
                    },
                  ),
                  Expanded(
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hm,
                      initialTimerDuration: selectedDuration,
                      onTimerDurationChanged: (value) {
                        selectedDuration = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  _addPreset(selectedGoal, selectedDuration);
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }*/

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StatsScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

  /*Widget _buildPresetCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                "Presets",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showAddPresetDialog,
                tooltip: "Add Preset",
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ..._presets.asMap().entries.map((entry) {
          final index = entry.key;
          final preset = entry.value;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TimerScreen(
                    duration: preset['duration'],
                    goal: preset['goal'],
                    skipBreak: _skipBreak,
                    focusTime: const Duration(minutes: 25),
                    breakTime: const Duration(minutes: 5),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${preset['goal']} - ${preset['duration'].inMinutes} phút",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _removePreset(index),
                    tooltip: "Delete Preset",
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }*/

  Widget _buildGoalSelector() {
    final goals = ['Study', 'Work', 'Relax', 'Sport', 'Entertainment', 'Other'];
    final goalColors = {
      'Study': Colors.blue,
      'Work': Colors.green,
      'Relax': Colors.orange,
      'Sport': Colors.red,
      'Entertainment': Colors.purple,
      'Other': Colors.grey,
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Goal",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Giá trị càng lớn càng bo tròn
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
                    selectedColor: goalColors[goal]?.withOpacity(0.2),
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? goalColors[goal] : Colors.black,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Focus Duration",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: _selectedDuration,
              onTimerDurationChanged: (value) =>
                  setState(() => _selectedDuration = value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Focus Timer"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /*const SizedBox(height: 10),
            _buildPresetCards(),*/
            const SizedBox(height: 20),
            _buildGoalSelector(),
            const SizedBox(height: 20),
            _buildTimePicker(),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              value: _skipBreak,
              onChanged: (val) => setState(() => _skipBreak = val),
              title: const Text("Skip break time"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
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
              child: const Text("Start"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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
