import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveSessionToFirestore({
  required String goal,
  required Duration duration,
  required DateTime timestamp,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final sessionData = {
    'userId': user.uid,
    'goal': goal,
    'duration': duration.inMinutes,
    'timestamp': timestamp,
  };

  await FirebaseFirestore.instance.collection('sessions').add(sessionData);
}

class TimerScreen extends StatefulWidget {
  final Duration duration;
  final String goal;
  final bool skipBreak;
  final Duration focusTime;
  final Duration breakTime;
  final Color goalColor;

  const TimerScreen({
    super.key,
    required this.duration,
    required this.goal,
    required this.skipBreak,
    required this.focusTime,
    required this.breakTime,
    required this.goalColor,
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

  void startCurrentPhase() async {
    if (currentPhaseIndex >= sessionPhases.length) {
      setState(() {
        currentLabel = "Done";
        currentPhaseRemaining = Duration.zero;
      });

      // ✅ Ghi dữ liệu lên Firestore
      await saveSessionToFirestore(
        goal: widget.goal,
        duration: widget.duration,
        timestamp: DateTime.now(),
      );

      // Optionally: tự động pop hoặc hiển thị thông báo
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
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

    // ✅ Luôn trả orientation về dọc
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
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Đổi nền về màu đen
      body: SafeArea(
        child: Stack(
          children: [
            // Nội dung chính
            isHorizontal
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
            // Nút quay lại ở góc trên bên trái
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  countdownTimer?.cancel();
                  Navigator.pop(context);
                },
                tooltip: "Back",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCircle() {
    if (currentPhaseIndex >= sessionPhases.length) {
      // Đồng hồ đã kết thúc hoàn toàn
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 12),
            Text(
              "Session Completed!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    final total = sessionPhases[currentPhaseIndex].duration.inSeconds;
    final remaining = currentPhaseRemaining.inSeconds;
    final percent = total == 0 ? 1.0 : (remaining / total);

    final color = currentLabel == "Break" ? Colors.orange : widget.goalColor;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Lấy cạnh nhỏ nhất để làm hình vuông lớn nhất có thể
          final size = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;
          final squareSize =
              size * 0.86; // 85% diện tích, có thể chỉnh lại nếu muốn

          return Container(
            width: squareSize,
            height: squareSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.5),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: squareSize * 0.73, // Giữ tỉ lệ với nền
                  height: squareSize * 0.73,
                  child: CircularPercentIndicator(
                    radius: squareSize * 0.365, // tương đương với width/2
                    lineWidth: squareSize * 0.07,
                    percent: percent.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    progressColor: color,
                    circularStrokeCap:
                        CircularStrokeCap.round, // Bo tròn hai đầu
                    /*center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatDuration(currentPhaseRemaining),
                          style: TextStyle(
                            fontSize: squareSize * 0.11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: squareSize * 0.03),
                        Text(
                          currentLabel,
                          style: TextStyle(
                            fontSize: squareSize * 0.07,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),*/
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatDuration(currentPhaseRemaining),
                      style: TextStyle(
                        fontSize: squareSize * 0.11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: squareSize * 0.03),
                    Text(
                      currentLabel,
                      style: TextStyle(
                        fontSize: squareSize * 0.07,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            "Phase ${currentPhaseIndex + 1} of ${sessionPhases.length}",
            style: const TextStyle(fontSize: 20, color: Colors.white),
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
