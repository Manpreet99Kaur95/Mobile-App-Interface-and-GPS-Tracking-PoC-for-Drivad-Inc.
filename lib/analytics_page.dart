import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text("Analytics"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("FR", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Campaign performance and insights",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          _impressionsReachCard(),
          const SizedBox(height: 16),

          _campaignPerformanceCard(),
          const SizedBox(height: 16),

          _statsCard(
            title: "Average Impressions/Campaign",
            value: "151,667",
            change: "+23% from last month",
            color: Colors.orange,
          ),
          const SizedBox(height: 12),

          _statsCard(
            title: "Average Reach/Campaign",
            value: "53,333",
            change: "+18% from last month",
            color: Colors.blue,
          ),
          const SizedBox(height: 12),

          _statsCard(
            title: "Engagement Rate",
            value: "35.2%",
            change: "+5% from last month",
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  // ---------------- LINE CHART ----------------
  Widget _impressionsReachCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Impressions & Reach Over Time",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text("Nov");
                            case 1:
                              return const Text("Dec");
                            case 2:
                              return const Text("Jan");
                          }
                          return const Text("");
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 40000),
                        FlSpot(1, 80000),
                        FlSpot(2, 130000),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 15000),
                        FlSpot(1, 30000),
                        FlSpot(2, 45000),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.circle, size: 10, color: Colors.blue),
                SizedBox(width: 4),
                Text("Impressions"),
                SizedBox(width: 16),
                Icon(Icons.circle, size: 10, color: Colors.green),
                SizedBox(width: 4),
                Text("Reach"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- BAR CHART ----------------
  Widget _campaignPerformanceCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Campaign Performance",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    _barGroup(0, 130000, 40000),
                    _barGroup(1, 260000, 80000),
                    _barGroup(2, 70000, 25000),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text("Coffee");
                            case 1:
                              return const Text("Tech");
                            case 2:
                              return const Text("Restaurant");
                          }
                          return const Text("");
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double impressions, double reach) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: impressions, color: Colors.blue, width: 14),
        BarChartRodData(toY: reach, color: Colors.green, width: 14),
      ],
    );
  }

  // ---------------- STATS CARD ----------------
  Widget _statsCard({
    required String title,
    required String value,
    required String change,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              change,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
