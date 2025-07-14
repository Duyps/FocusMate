import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, int> goalDurations = {};
  bool isLoading = true;

  final List<String> goals = [
    'Study',
    'Work',
    'Relax',
    'Sport',
    'Entertainment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    fetchSessionData();
  }

  Future<void> fetchSessionData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final snapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('userId', isEqualTo: user.uid)
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
        )
        .get();

    final Map<String, int> tempMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String goal = data['goal'] ?? 'Other';
      final int duration = data['duration'] ?? 0;

      tempMap[goal] = (tempMap[goal] ?? 0) + duration;
    }

    setState(() {
      goalDurations = tempMap;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _buildChartData();

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Stats'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Time spent per goal (last 7 days)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: chartData.maxY.toDouble() + 10,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}m',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= goals.length) {
                                  return const SizedBox.shrink();
                                }
                                return Transform.rotate(
                                  angle: -0.5,
                                  child: Text(
                                    goals[index],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(),
                          rightTitles: AxisTitles(),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: chartData.barGroups,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  _ChartData _buildChartData() {
    List<BarChartGroupData> groups = [];
    int maxValue = 0;

    for (int i = 0; i < goals.length; i++) {
      final goal = goals[i];
      final minutes = goalDurations[goal] ?? 0;
      maxValue = minutes > maxValue ? minutes : maxValue;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: minutes.toDouble(),
              width: 20,
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.primary,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxValue.toDouble() + 10,
                color: Colors.grey.shade200,
              ),
            ),
          ],
        ),
      );
    }

    return _ChartData(barGroups: groups, maxY: maxValue);
  }
}

class _ChartData {
  final List<BarChartGroupData> barGroups;
  final int maxY;

  _ChartData({required this.barGroups, required this.maxY});
}
