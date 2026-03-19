// lib/dashboards/advertiser_dashboard_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../language_provider.dart';
import '../auth/auth_service.dart';
import '../widgets/app_drawer.dart';

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

class AdvertiserDashboardPage extends StatefulWidget {
  final AuthService auth;
  const AdvertiserDashboardPage({super.key, required this.auth});

  @override
  State<AdvertiserDashboardPage> createState() =>
      _AdvertiserDashboardPageState();
}

class _AdvertiserDashboardPageState extends State<AdvertiserDashboardPage> {
  Future<void> _logout() async => widget.auth.logout();

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    const currentRoute = '/dashboard';
    final userId = widget.auth.currentUser?.uid;

    final userName = widget.auth.currentUser?.displayName?.trim();
    final shownName = (userName == null || userName.isEmpty)
        ? lp.translate('advertiser')
        : userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: AppDrawer(
        role: AppRole.advertiser,
        activeRoute: currentRoute,
        onLogout: _logout,
      ),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          lp.translate('dashboard'),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0B1220),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _PillButton(
              icon: Icons.language,
              label: lp.lang.toUpperCase(),
              onTap: () => lp.toggleLanguage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                shownName,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _PillButton(
              icon: Icons.logout,
              label: lp.translate('logout'),
              onTap: _logout,
            ),
          ),
        ],
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

                // Calculate stats
                final activeCampaigns = campaigns
                    .where((c) => c.isActive)
                    .length;

                final totalSpent = campaigns.fold<double>(0.0, (total, c) {
                  final budgetString = c.budget.replaceAll(
                    RegExp(r'[^\d.]'),
                    '',
                  );
                  return total + (double.tryParse(budgetString) ?? 0.0);
                });

                final totalImpressions = campaigns.fold<int>(0, (total, c) {
                  final impressionsString = c.impressions.replaceAll(
                    RegExp(r'[^\d]'),
                    '',
                  );
                  final value = int.tryParse(impressionsString) ?? 0;
                  return total +
                      (c.impressions.contains('k') ? value * 1000 : value);
                });

                final totalReach = campaigns.fold<int>(0, (total, c) {
                  final reachString = c.reach.replaceAll(RegExp(r'[^\d]'), '');
                  final value = int.tryParse(reachString) ?? 0;
                  return total + (c.reach.contains('k') ? value * 1000 : value);
                });

                return LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 900;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lp.translate('welcome_back'),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lp.translate('statistics'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(150),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Stats Cards with real data
                              if (isWide)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        title: lp.translate('active_campaigns'),
                                        value: activeCampaigns.toString(),
                                        icon: Icons.campaign,
                                        iconBg: const Color(0xFFEAF2FF),
                                        iconFg: const Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _StatCard(
                                        title: lp.translate('total_spent'),
                                        value:
                                            '\$${totalSpent.toStringAsFixed(0)}',
                                        icon: Icons.attach_money,
                                        iconBg: const Color(0xFFE8F7EE),
                                        iconFg: const Color(0xFF16A34A),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _StatCard(
                                        title: lp.translate('impressions'),
                                        value:
                                            '${(totalImpressions / 1000).toStringAsFixed(0)}k',
                                        icon: Icons.visibility,
                                        iconBg: const Color(0xFFF3E8FF),
                                        iconFg: const Color(0xFF7C3AED),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _StatCard(
                                        title: lp.translate('reach'),
                                        value:
                                            '${(totalReach / 1000).toStringAsFixed(0)}k',
                                        icon: Icons.people_alt,
                                        iconBg: const Color(0xFFFFEDD5),
                                        iconFg: const Color(0xFFEA580C),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    _StatCard(
                                      title: lp.translate('active_campaigns'),
                                      value: activeCampaigns.toString(),
                                      icon: Icons.campaign,
                                      iconBg: const Color(0xFFEAF2FF),
                                      iconFg: const Color(0xFF2563EB),
                                    ),
                                    const SizedBox(height: 12),
                                    _StatCard(
                                      title: lp.translate('total_spent'),
                                      value:
                                          '\$${totalSpent.toStringAsFixed(0)}',
                                      icon: Icons.attach_money,
                                      iconBg: const Color(0xFFE8F7EE),
                                      iconFg: const Color(0xFF16A34A),
                                    ),
                                    const SizedBox(height: 12),
                                    _StatCard(
                                      title: lp.translate('impressions'),
                                      value:
                                          '${(totalImpressions / 1000).toStringAsFixed(0)}k',
                                      icon: Icons.visibility,
                                      iconBg: const Color(0xFFF3E8FF),
                                      iconFg: const Color(0xFF7C3AED),
                                    ),
                                    const SizedBox(height: 12),
                                    _StatCard(
                                      title: lp.translate('reach'),
                                      value:
                                          '${(totalReach / 1000).toStringAsFixed(0)}k',
                                      icon: Icons.people_alt,
                                      iconBg: const Color(0xFFFFEDD5),
                                      iconFg: const Color(0xFFEA580C),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 16),

                              // Campaigns Section with real data
                              _SectionCard(
                                title: lp.translate('my_campaigns'),
                                trailing: campaigns.isNotEmpty
                                    ? TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/campaigns',
                                          );
                                        },
                                        child: Text(lp.translate('view_all')),
                                      )
                                    : null,
                                child: campaigns.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 32,
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.campaign_outlined,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                lp.translate(
                                                  'no_campaigns_yet',
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/campaigns',
                                                  );
                                                },
                                                icon: const Icon(Icons.add),
                                                label: Text(
                                                  lp.translate(
                                                    'create_campaign',
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: campaigns.take(5).map((
                                          campaign,
                                        ) {
                                          return Column(
                                            children: [
                                              _CampaignRow(
                                                title: campaign.title,
                                                subtitle:
                                                    '${campaign.drivers} ${lp.translate('drivers')} • ${campaign.impressions} ${lp.translate('impressions')}',
                                                status: campaign.isActive
                                                    ? lp.translate('active')
                                                    : lp.translate('inactive'),
                                                isActive: campaign.isActive,
                                              ),
                                              if (campaign !=
                                                  campaigns.take(5).last)
                                                Divider(
                                                  height: 18,
                                                  color: Theme.of(
                                                    context,
                                                  ).dividerColor.withAlpha(120),
                                                ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).dividerColor.withAlpha(90)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconFg, size: 18),
        ),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).dividerColor.withAlpha(90)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class _CampaignRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final bool isActive;

  const _CampaignRow({
    required this.title,
    required this.subtitle,
    required this.status,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F7EE) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isActive ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
          ),
        ),
      ),
    ],
  );
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(999),
    child: InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Theme.of(context).dividerColor.withAlpha(110),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    ),
  );
}
