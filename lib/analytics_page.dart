import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'auth/auth_service.dart';
import 'widgets/app_drawer.dart';

// Campaign model defined here to avoid import issues
class Campaign {
  final String id;
  final String title;
  final String description;
  final String budget;
  final String duration;
  final String impressions;
  final String reach;
  final String location;
  final String applicants;
  final String drivers;
  final bool isActive;
  final String advertiserId;
  final DateTime? createdAt;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.duration,
    required this.impressions,
    required this.reach,
    required this.location,
    required this.applicants,
    required this.drivers,
    this.isActive = true,
    required this.advertiserId,
    this.createdAt,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      budget: data['budget'] ?? '\$0',
      duration: data['duration'] ?? '0 days',
      impressions: data['impressions'] ?? '0',
      reach: data['reach'] ?? '0',
      location: data['location'] ?? '',
      applicants: data['applicants']?.toString() ?? '0',
      drivers: data['drivers']?.toString() ?? '0',
      isActive: data['isActive'] ?? true,
      advertiserId: data['advertiserId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  final AuthService auth;
  const AnalyticsPage({super.key, required this.auth});

  Future<void> _logout() async => auth.logout();

  Future<AppRole> _loadRole() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return AppRole.driver;
    final role = (await auth.getOrCreateUserRole(uid)).toLowerCase();
    return role == 'advertiser' ? AppRole.advertiser : AppRole.driver;
  }

  // Calculate statistics from campaigns
  Map<String, dynamic> _calculateStats(List<Campaign> campaigns) {
    if (campaigns.isEmpty) {
      return {
        'avgImpressions': 0,
        'avgReach': 0,
        'engagementRate': 0.0,
        'totalImpressions': 0,
        'totalReach': 0,
      };
    }

    final totalImpressions = campaigns.fold<int>(0, (total, c) {
      final impressionsString = c.impressions.replaceAll(RegExp(r'[^\d]'), '');
      final value = int.tryParse(impressionsString) ?? 0;
      return total + (c.impressions.contains('k') ? value * 1000 : value);
    });

    final totalReach = campaigns.fold<int>(0, (total, c) {
      final reachString = c.reach.replaceAll(RegExp(r'[^\d]'), '');
      final value = int.tryParse(reachString) ?? 0;
      return total + (c.reach.contains('k') ? value * 1000 : value);
    });

    final avgImpressions = totalImpressions ~/ campaigns.length;
    final avgReach = totalReach ~/ campaigns.length;
    final engagementRate = totalImpressions > 0
        ? (totalReach / totalImpressions) * 100
        : 0.0;

    return {
      'avgImpressions': avgImpressions,
      'avgReach': avgReach,
      'engagementRate': engagementRate,
      'totalImpressions': totalImpressions,
      'totalReach': totalReach,
    };
  }

  // Generate chart data from campaigns
  List<FlSpot> _generateImpressionSpots(List<Campaign> campaigns) {
    if (campaigns.isEmpty) return [const FlSpot(0, 0)];

    return campaigns.asMap().entries.map((entry) {
      final c = entry.value;
      final impressionsString = c.impressions.replaceAll(RegExp(r'[^\d]'), '');
      final value = int.tryParse(impressionsString) ?? 0;
      final impressions = c.impressions.contains('k') ? value * 1000 : value;
      return FlSpot(entry.key.toDouble(), impressions.toDouble());
    }).toList();
  }

  List<FlSpot> _generateReachSpots(List<Campaign> campaigns) {
    if (campaigns.isEmpty) return [const FlSpot(0, 0)];

    return campaigns.asMap().entries.map((entry) {
      final c = entry.value;
      final reachString = c.reach.replaceAll(RegExp(r'[^\d]'), '');
      final value = int.tryParse(reachString) ?? 0;
      final reach = c.reach.contains('k') ? value * 1000 : value;
      return FlSpot(entry.key.toDouble(), reach.toDouble());
    }).toList();
  }

  List<BarChartGroupData> _generateBarGroups(List<Campaign> campaigns) {
    if (campaigns.isEmpty) return [];

    return campaigns.asMap().entries.map((entry) {
      final c = entry.value;
      final impressionsString = c.impressions.replaceAll(RegExp(r'[^\d]'), '');
      final reachString = c.reach.replaceAll(RegExp(r'[^\d]'), '');
      final impressionsValue = int.tryParse(impressionsString) ?? 0;
      final reachValue = int.tryParse(reachString) ?? 0;
      final impressions = c.impressions.contains('k')
          ? impressionsValue * 1000
          : impressionsValue;
      final reach = c.reach.contains('k') ? reachValue * 1000 : reachValue;

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: impressions.toDouble(),
            color: Colors.blue,
            width: 14,
          ),
          BarChartRodData(
            toY: reach.toDouble(),
            color: Colors.green,
            width: 14,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    const currentRoute = '/analytics';
    final userId = auth.currentUser?.uid;

    return FutureBuilder<AppRole>(
      future: _loadRole(),
      builder: (context, snap) {
        final role = snap.data ?? AppRole.driver;

        // RESTRICTION: If not an advertiser, show "Access Denied" or empty state
        if (role != AppRole.advertiser) {
          return Scaffold(
            appBar: AppBar(title: Text(lp.translate('analytics'))),
            drawer: AppDrawer(
              role: role,
              activeRoute: currentRoute,
              onLogout: _logout,
            ),
            body: Center(
              child: Text(
                lp.lang == 'en'
                    ? "Analytics are only available for Advertisers"
                    : "Les analyses sont uniquement disponibles pour les annonceurs",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xfff5f6fa),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              lp.translate('analytics'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => lp.toggleLanguage(),
                icon: const Icon(Icons.language),
              ),
            ],
          ),
          drawer: AppDrawer(
            role: role,
            activeRoute: currentRoute,
            onLogout: _logout,
          ),
          body: userId == null
              ? const Center(child: Text('Please sign in'))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('campaigns')
                      .where('advertiserId', isEqualTo: userId)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final campaigns =
                        snapshot.data?.docs
                            .map((doc) => Campaign.fromFirestore(doc))
                            .toList() ??
                        [];

                    final stats = _calculateStats(campaigns);
                    final impressionSpots = _generateImpressionSpots(campaigns);
                    final reachSpots = _generateReachSpots(campaigns);
                    final barGroups = _generateBarGroups(campaigns);

                    // Calculate percentage changes (mock logic - compare with previous period)
                    final impressionsChange = campaigns.length > 1
                        ? "+23%"
                        : "+0%";
                    final reachChange = campaigns.length > 1 ? "+18%" : "+0%";
                    final engagementChange = stats['engagementRate'] > 30
                        ? "+5%"
                        : "+0%";

                    return SafeArea(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lp.translate('campaign_performance'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Line Chart - Impressions vs Reach Over Time
                              _impressionsReachCard(
                                lp,
                                impressionSpots,
                                reachSpots,
                              ),
                              const SizedBox(height: 16),

                              // Bar Chart - Campaign Performance
                              _campaignPerformanceCard(lp, barGroups),
                              const SizedBox(height: 16),

                              // Stats Cards with real data
                              _statsCard(
                                title: lp.translate('avg_impressions'),
                                value:
                                    "${(stats['avgImpressions'] / 1000).toStringAsFixed(0)}k",
                                change:
                                    "$impressionsChange ${lp.translate('from_last_month')}",
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 12),
                              _statsCard(
                                title: lp.translate('avg_reach'),
                                value:
                                    "${(stats['avgReach'] / 1000).toStringAsFixed(0)}k",
                                change:
                                    "$reachChange ${lp.translate('from_last_month')}",
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 12),
                              _statsCard(
                                title: lp.translate('engagement_rate'),
                                value:
                                    "${stats['engagementRate'].toStringAsFixed(1)}%",
                                change:
                                    "$engagementChange ${lp.translate('from_last_month')}",
                                color: Colors.green,
                              ),

                              // Summary Card
                              if (campaigns.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _summaryCard(
                                  lp,
                                  campaigns.length,
                                  stats['totalImpressions'],
                                  stats['totalReach'],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _impressionsReachCard(
    LanguageProvider lp,
    List<FlSpot> impressionSpots,
    List<FlSpot> reachSpots,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lp.translate('impressions_reach_time'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: impressionSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: reachSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, size: 10, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  lp.translate('impressions'),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.circle, size: 10, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  lp.translate('reach'),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _campaignPerformanceCard(
    LanguageProvider lp,
    List<BarChartGroupData> barGroups,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lp.translate('campaign_performance'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: barGroups.isEmpty
                  ? const Center(child: Text('No data available'))
                  : BarChart(
                      BarChartData(
                        barGroups: barGroups,
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsCard({
    required String title,
    required String value,
    required String change,
    required Color color,
  }) {
    return Card(
      elevation: 1,
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
            Text(change, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    LanguageProvider lp,
    int campaignCount,
    int totalImpressions,
    int totalReach,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1A1A2E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lp.translate('my_campaigns'),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              campaignCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lp.translate('impressions'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "${(totalImpressions / 1000).toStringAsFixed(0)}k",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lp.translate('reach'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "${(totalReach / 1000).toStringAsFixed(0)}k",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
