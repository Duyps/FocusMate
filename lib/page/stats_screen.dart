import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, int> goalDurations = {};
  bool loading = true;

  final List<String> goalOrder = [
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
    fetchWeeklyStats();
  }

  Future<void> fetchWeeklyStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final startOfWeekMidnight = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    final snapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfWeekMidnight)
        .get();

    final Map<String, int> totals = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final goal = data['goal'] ?? 'Other';
      final duration = data['duration'] ?? 0;
      //totals[goal] = (totals[goal] ?? 0) + duration;
    }

    setState(() {
      goalDurations = totals;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        //appBar: AppBar(title: Text("Stats")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("This Week's Time Usage"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: getMaxY().toDouble() + 10,
            barGroups: goalOrder.map((goal) {
              final value = goalDurations[goal] ?? 0;
              return BarChartGroupData(
                x: goalOrder.indexOf(goal),
                barRods: [
                  BarChartRodData(
                    toY: value.toDouble(),
                    width: 18,
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double val, _) {
                    final goal = goalOrder[val.toInt()];
                    return Text(goal, style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, interval: 10),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: true),
          ),
        ),
      ),
    );
  }

  int getMaxY() {
    if (goalDurations.isEmpty) return 60;
    return goalDurations.values.reduce((a, b) => a > b ? a : b);
  }
}
