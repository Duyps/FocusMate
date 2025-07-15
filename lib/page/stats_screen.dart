import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, int> todayStats = {};
  Map<String, List<int>> weeklyStats = {};
  Map<String, int> monthlyStats = {};
  bool isLoading = true;

  final Map<String, Color> goalColors = {
    'Study': const Color.fromARGB(255, 94, 160, 215),
    'Work': const Color.fromARGB(255, 101, 195, 104),
    'Relax': const Color.fromARGB(255, 255, 186, 81),
    'Sport': const Color.fromARGB(255, 255, 117, 107),
    'Entertainment': const Color.fromARGB(255, 169, 95, 183),
    'Other': Colors.grey,
  };

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

    final todayMap = <String, int>{};
    final weekMap = <String, List<int>>{};
    final monthMap = <String, int>{};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final goal = data['goal'] ?? 'Other';
      final duration = (data['duration'] ?? 0) as num;
      final ts = (data['timestamp'] as Timestamp).toDate();

      if (ts.isAfter(todayStart)) {
        todayMap[goal] = (todayMap[goal] ?? 0) + duration.toInt();
      }

      if (ts.isAfter(weekStart)) {
        int dayOffset = ts.difference(weekStart).inDays;
        weekMap.putIfAbsent(goal, () => List.filled(7, 0));
        weekMap[goal]![dayOffset] += duration.toInt();
      }

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
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          title: const Text("⏱️ Time Statistics"),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.blueAccent,
            tabs: const [
              Tab(text: "Today"),
              Tab(text: "Week"),
              Tab(text: "Month"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : TabBarView(
                controller: _tabController,
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
    if (todayStats.isEmpty) {
      return const Center(
        child: Text(
          "No data for today",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final total = todayStats.values.fold(0, (a, b) => a + b);
    final sections = todayStats.entries.map((e) {
      final percentage = (e.value / total) * 100;
      return PieChartSectionData(
        color: goalColors[e.key],
        value: e.value.toDouble(),
        title: "${e.key}\n${percentage.toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    if (weeklyStats.isEmpty) {
      return const Center(
        child: Text(
          "No data for this week",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final goalList = weeklyStats.keys.toList();

    final barGroups = List.generate(7, (i) {
      final rods = goalList.map((goal) {
        final value = weeklyStats[goal]![i].toDouble();
        return BarChartRodData(
          toY: value,
          width: 14,
          color: goalColors[goal] ?? Colors.grey,
          borderRadius: BorderRadius.circular(6),
        );
      }).toList();
      return BarChartGroupData(x: i, barRods: rods);
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 30,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: barGroups,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    if (monthlyStats.isEmpty) {
      return const Center(
        child: Text(
          "No data for this month",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final total = monthlyStats.values.fold(0, (a, b) => a + b);
    final sections = monthlyStats.entries.map((e) {
      final percentage = (e.value / total) * 100;
      return PieChartSectionData(
        color: goalColors[e.key],
        value: e.value.toDouble(),
        title: "${e.key}\n${percentage.toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
