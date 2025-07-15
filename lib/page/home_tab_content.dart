import 'package:flashcard/page/model/preset.dart';
import 'package:flashcard/page/services/preset_storage.dart';
import 'package:flashcard/page/widgets/create_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../page/timer_screen.dart';

class HomeTabContent extends StatefulWidget {
  const HomeTabContent({super.key});

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  String _getGreeting(String? name) {
    final hour = DateTime.now().hour;
    String greet;
    if (hour < 12) {
      greet = 'Good morning';
    } else if (hour < 18) {
      greet = 'Good afternoon';
    } else {
      greet = 'Good evening';
    }
    return "$greet${name != null ? ', $name' : ''}!";
  }

  final Map<String, Color> goalColors = {
    'Study': const Color.fromARGB(255, 94, 160, 215), // xanh dương
    'Work': const Color.fromARGB(255, 101, 195, 104), // xanh lá
    'Relax': const Color.fromARGB(255, 255, 186, 81), // vàng
    'Sport': const Color.fromARGB(255, 255, 117, 107), // đỏ
    'Entertainment': const Color.fromARGB(255, 169, 95, 183), // tím
    'Other': Colors.grey,
  };

  final List<Preset> _presets = [];
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final presets = await PresetStorage.loadPresetsForUser(user.uid);
    if (!mounted) return;
    setState(() {
      _presets.clear();
      _presets.addAll(presets);
    });
  }

  void _addPreset(
    String name,
    String goal,
    Duration duration,
    bool skipBreak,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final preset = Preset(
      id: '', // Firestore sẽ tự sinh id
      userId: user.uid,
      name: name,
      goal: goal,
      duration: duration,
      skipBreak: skipBreak,
    );

    await PresetStorage.addPreset(preset);
    _loadPresets(); // tải lại từ Firestore
  }

  Future<void> _deletePreset(Preset preset) async {
    await PresetStorage.deletePreset(preset.id);
    _loadPresets(); // reload sau khi xóa
  }

  void _showAddPresetDialog() {
    String name = '';
    String goal = 'Study';
    Duration duration = const Duration(minutes: 25);
    bool skipBreak = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Create Preset'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (val) => name = val,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: goal,
                      onChanged: (val) =>
                          setStateDialog(() => goal = val ?? 'Study'),
                      items:
                          [
                                'Study',
                                'Work',
                                'Relax',
                                'Sport',
                                'Entertainment',
                                'Other',
                              ]
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Minutes: '),
                        Expanded(
                          child: Slider(
                            value: duration.inMinutes.toDouble(),
                            min: 5,
                            max: 120,
                            divisions: 23,
                            label: '${duration.inMinutes} min',
                            onChanged: (value) => setStateDialog(
                              () => duration = Duration(minutes: value.toInt()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      title: const Text('Skip Break'),
                      value: skipBreak,
                      onChanged: (val) =>
                          setStateDialog(() => skipBreak = val ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    final newPreset = Preset(
                      id: const Uuid().v4(),
                      userId: user.uid, // ✅ THÊM userId
                      name: name,
                      goal: goal,
                      duration: duration,
                      skipBreak: skipBreak,
                    );

                    await PresetStorage.addPreset(
                      newPreset,
                    ); // gọi đúng storage xử lý Firestore
                    _loadPresets(); // reload lại list preset
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@').first;
    final greeting = _getGreeting(displayName);
    final now = DateTime.now();
    final formattedDate = DateFormat(
      'EEEE, MMM d, yyyy',
    ).format(DateTime.now());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              greeting,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              formattedDate,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 40),
          const CreateWidget(),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _showAddPresetDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Preset',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          ..._presets.map((preset) => _buildPresetCard(preset)),
        ],
      ),
    );
  }

  Widget _buildPresetCard(Preset preset) {
    final bgColor =
        goalColors[preset.goal]?.withOpacity(0.2) ??
        Colors.grey.withOpacity(0.2);
    final iconColor = goalColors[preset.goal] ?? Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '${preset.name} • ${preset.goal} – ${preset.duration.inMinutes} min',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Row(
            children: [
              // Icon START
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TimerScreen(
                        duration: preset.duration,
                        goal: preset.goal,
                        skipBreak: preset.skipBreak,
                        focusTime: const Duration(minutes: 25),
                        breakTime: const Duration(minutes: 5),
                        goalColor: iconColor,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Icon(
                    Icons.play_circle_fill_outlined,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Icon DELETE
              GestureDetector(
                onTap: () => _deletePreset(preset),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    //color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
