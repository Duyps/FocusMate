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
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF1E1E1E),
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              "Time Statistics",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Today"),
                    Tab(text: "Week"),
                    Tab(text: "Month"),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayChart(),
                    _buildWeeklyChart(),
                    _buildMonthlyChart(),
                  ],
                ),
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
          shadows: [
            Shadow(color: Colors.black87, offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Time by Goal (Today)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: todayStats.keys.map((goal) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: goalColors[goal] ?? Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      goal,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Focus Time by Goal",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(7, (dayIndex) {
                    return BarChartGroupData(
                      x: dayIndex,
                      barRods: List.generate(goalList.length, (goalIndex) {
                        final goal = goalList[goalIndex];
                        final value = weeklyStats[goal]![dayIndex].toDouble();
                        return BarChartRodData(
                          toY: value,
                          width: 8,
                          color: goalColors[goal] ?? Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        );
                      }),
                      showingTooltipIndicators: [0],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 30,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        reservedSize: 28,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text(
                          days[value.toInt()],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true, horizontalInterval: 30),
                  borderData: FlBorderData(show: false),
                  alignment: BarChartAlignment.spaceBetween,
                  maxY: _calculateMaxY(weeklyStats),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: goalList.map((goal) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: goalColors[goal] ?? Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      goal,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY(Map<String, List<int>> weeklyStats) {
    int max = 0;
    for (var dayValues in weeklyStats.values) {
      for (var v in dayValues) {
        if (v > max) max = v;
      }
    }
    return ((max + 29) ~/ 30) * 30.0; // làm tròn lên bội số 30
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

    final sections = monthlyStats.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: goalColors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: "${entry.key}\n${percentage.toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 3, color: Colors.black54, offset: Offset(1, 1)),
          ],
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Time by Goal (This Month)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: monthlyStats.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: goalColors[entry.key] ?? Colors.grey,
                      ),
                    ),
                    Text(
                      "${entry.key}: ${entry.value} min",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
