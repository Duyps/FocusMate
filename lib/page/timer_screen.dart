import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerScreen extends StatefulWidget {
  final Duration duration;
  final String goal;
  final bool skipBreak;
  final Duration focusTime;
  final Duration breakTime;

  const TimerScreen({
    super.key,
    required this.duration,
    required this.goal,
    required this.skipBreak,
    required this.focusTime,
    required this.breakTime,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class SessionPhase {
  final String label; // "Focus" or "Break"
  final Duration duration;

  SessionPhase({required this.label, required this.duration});
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  List<SessionPhase> sessionPhases = [];
  int currentPhaseIndex = 0;
  Duration currentPhaseRemaining = Duration.zero;
  String currentLabel = "Focus";

  Timer? countdownTimer;
  late AnimationController progressController;

  bool get isHorizontal => widget.goal == 'Study' || widget.goal == 'Work';

  @override
  void initState() {
    super.initState();

    // Xoay ngang nếu là Study/Work
    if (isHorizontal) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }

    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // sẽ cập nhật sau
    );

    generateSessionPhases();
    startCurrentPhase();
  }

  void generateSessionPhases() {
    if (widget.skipBreak) {
      sessionPhases = [SessionPhase(label: "Focus", duration: widget.duration)];
      return;
    }

    final focusTime = widget.focusTime;
    final breakTime = widget.breakTime;
    Duration remainingTime = widget.duration;

    while (remainingTime >= focusTime) {
      sessionPhases.add(SessionPhase(label: "Focus", duration: focusTime));
      remainingTime -= focusTime;

      if (remainingTime >= breakTime) {
        sessionPhases.add(SessionPhase(label: "Break", duration: breakTime));
        remainingTime -= breakTime;
      }
    }

    if (remainingTime.inMinutes > 0) {
      sessionPhases.add(SessionPhase(label: "Focus", duration: remainingTime));
    }
  }

  void startCurrentPhase() {
    if (currentPhaseIndex >= sessionPhases.length) {
      // Kết thúc toàn bộ session
      setState(() {
        currentLabel = "Done";
        currentPhaseRemaining = Duration.zero;
      });
      return;
    }

    SessionPhase phase = sessionPhases[currentPhaseIndex];
    currentLabel = phase.label;
    currentPhaseRemaining = phase.duration;

    progressController.duration = phase.duration;
    progressController.reset();
    progressController.forward();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentPhaseRemaining.inSeconds <= 1) {
        timer.cancel();
        progressController.stop();

        setState(() {
          currentPhaseIndex++;
        });

        Future.delayed(const Duration(milliseconds: 500), startCurrentPhase);
      } else {
        setState(() {
          currentPhaseRemaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    progressController.dispose();

    // Trả lại portrait khi thoát
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Focus on ${widget.goal}"), centerTitle: true),
      body: isHorizontal
          ? Row(
              children: [
                Expanded(child: _buildTimerCircle()),
                Expanded(child: _buildInfoPanel()),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildTimerCircle()),
                _buildInfoPanel(),
              ],
            ),
    );
  }

  Widget _buildTimerCircle() {
    final total = sessionPhases.isEmpty
        ? 1
        : sessionPhases[currentPhaseIndex].duration.inSeconds;
    final remaining = currentPhaseRemaining.inSeconds;
    final percent = total == 0 ? 1.0 : (remaining / total);

    final color = currentLabel == "Break"
        ? Colors.orange
        : Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatDuration(currentPhaseRemaining),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(currentLabel, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 32),
          const SizedBox(height: 8),
          Text(
            "Phase ${currentPhaseIndex + 1} of ${sessionPhases.length}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              countdownTimer?.cancel();
              Navigator.pop(context);
            },
            child: const Text("Stop"),
          ),
        ],
      ),
    );
  }
}
