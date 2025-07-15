import 'package:flashcard/page/model/preset.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flashcard/page/timer_screen.dart';

class CreateWidget extends StatefulWidget {
  const CreateWidget({super.key});

  @override
  State<CreateWidget> createState() => _CreateWidgetState();
}

class _CreateWidgetState extends State<CreateWidget> {
  Duration _selectedDuration = const Duration(minutes: 25);
  String _selectedGoal = 'Study';
  bool _skipBreak = false;
  bool _expanded = false;

  final Map<String, Color> goalColors = {
    'Study': const Color.fromARGB(255, 94, 160, 215),
    'Work': const Color.fromARGB(255, 101, 195, 104),
    'Relax': const Color.fromARGB(255, 255, 186, 81),
    'Sport': const Color.fromARGB(255, 255, 117, 107),
    'Entertainment': const Color.fromARGB(255, 169, 95, 183),
    'Other': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _expanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: GestureDetector(
        onTap: () => setState(() => _expanded = true),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 200,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 180, 160, 255),
            borderRadius: BorderRadius.circular(30),
            image: DecorationImage(
              image: AssetImage('assets/images/bg.png'),
              fit: BoxFit.contain, // hoặc BoxFit.none, BoxFit.cover
              alignment:
                  Alignment.bottomRight, // vị trí ảnh (ví dụ: góc phải dưới)
              scale: 1.5, // nhỏ hơn 1.0 sẽ phóng to, lớn hơn sẽ thu nhỏ
            ),
          ),
          child: Stack(
            children: [
              // Dòng chữ Daily Challenge - góc trên trái
              const Positioned(
                top: 16,
                left: 16,
                child: Text(
                  'Daily \nChallenge',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2), // vị trí bóng (ngang, dọc)
                        blurRadius: 8.0, // độ mờ
                        color: Color.fromARGB(255, 147, 147, 147), // màu bóng
                      ),
                    ],
                  ),
                ),
              ),

              // Dòng create session và icon - góc dưới phải
              Positioned(
                bottom: 16,
                left: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Create new session',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2), // vị trí bóng (ngang, dọc)
                            blurRadius: 5.0, // độ mờ
                            color: Color.fromARGB(42, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      secondChild: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalSelector(),
            const SizedBox(height: 16),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
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
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _expanded = false),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    final goals = goalColors.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Goal",
          style: TextStyle(fontSize: 18, color: Colors.white),
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
                  label: Text(goal),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedGoal = goal),
                  selectedColor: goalColors[goal]?.withOpacity(0.25),
                  backgroundColor: Colors.grey[850],
                  labelStyle: TextStyle(
                    color: isSelected ? goalColors[goal] : Colors.white,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30,
                    ), // Tăng bo góc tại đây
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Focus Duration",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
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
    );
  }
}
