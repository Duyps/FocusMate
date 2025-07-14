import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, int> todayStats = {};
  Map<String, List<int>> weeklyStats = {}; // key: goal, value: list of 7 days
  Map<String, int> monthlyStats = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadStats();
  }

  Future<void> loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final snapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('userId', isEqualTo: user.uid)
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
        )
        .get();

    final List<QueryDocumentSnapshot> docs = snapshot.docs;

    final todayMap = <String, int>{};
    final weekMap = <String, List<int>>{};
    final monthMap = <String, int>{};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final goal = data['goal'] ?? 'Other';
      final duration = (data['duration'] ?? 0) as num;
      final ts = (data['timestamp'] as Timestamp).toDate();

      // Hôm nay
      if (ts.isAfter(todayStart)) {
        todayMap[goal] = (todayMap[goal] ?? 0) + duration.toInt();
      }

      // Tuần
      if (ts.isAfter(weekStart)) {
        int dayOffset = ts.difference(weekStart).inDays;
        weekMap.putIfAbsent(goal, () => List.filled(7, 0));
        weekMap[goal]![dayOffset] += duration.toInt();
      }

      // Tháng
      monthMap[goal] = (monthMap[goal] ?? 0) + duration.toInt();
    }

    setState(() {
      todayStats = todayMap;
      weeklyStats = weekMap;
      monthlyStats = monthMap;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Thống kê thời gian"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Hôm nay"),
              Tab(text: "Tuần"),
              Tab(text: "Tháng"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildTodayChart(),
                  _buildWeeklyChart(),
                  _buildMonthlyChart(),
                ],
              ),
      ),
    );
  }

  Widget _buildTodayChart() {
    if (todayStats.isEmpty)
      return const Center(child: Text("Không có dữ liệu hôm nay"));

    final total = todayStats.values.fold(0, (a, b) => a + b);
    final sections = todayStats.entries.map((e) {
      final percentage = (e.value / total) * 100;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: "${e.key}\n${percentage.toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 40)),
    );
  }

  Widget _buildWeeklyChart() {
    if (weeklyStats.isEmpty)
      return const Center(child: Text("Không có dữ liệu tuần này"));

    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final barGroups = List.generate(7, (i) {
      final rods = weeklyStats.entries.map((entry) {
        final value = entry.value[i].toDouble();
        return BarChartRodData(toY: value, width: 8);
      }).toList();

      return BarChartGroupData(x: i, barRods: rods);
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(days[value.toInt()]),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 30),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: barGroups,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    if (monthlyStats.isEmpty)
      return const Center(child: Text("Không có dữ liệu tháng này"));

    final total = monthlyStats.values.fold(0, (a, b) => a + b);
    final sections = monthlyStats.entries.map((e) {
      final percentage = (e.value / total) * 100;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: "${e.key}\n${percentage.toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 40)),
    );
  }
}
