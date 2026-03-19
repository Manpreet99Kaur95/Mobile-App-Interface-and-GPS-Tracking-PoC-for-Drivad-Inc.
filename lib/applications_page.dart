import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'widgets/app_drawer.dart';
import 'auth/auth_service.dart';

class ApplicationsPage extends StatelessWidget {
  final AuthService auth;
  const ApplicationsPage({super.key, required this.auth});

  Future<void> _logout() async => auth.logout();

  Future<AppRole> _loadRole() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return AppRole.driver;

    final role = (await auth.getOrCreateUserRole(uid)).toLowerCase();
    return role == 'advertiser' ? AppRole.advertiser : AppRole.driver;
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);

    const currentRoute = '/applications';

    return FutureBuilder<AppRole>(
      future: _loadRole(),
      builder: (context, snap) {
        final role = snap.data ?? AppRole.driver;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              lp.translate('applications'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              IconButton(
                tooltip: lp.translate('language'),
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

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lp.translate('track_applications'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildApplicationCard(
                    context,
                    lp,
                    title: 'Downtown Coffee Shop Promo',
                    appliedDate: '2026-01-02',
                    status: lp.translate('approved'),
                    statusColor: Colors.black,
                    vehicleInfo: '2022 Toyota Camry',
                    licensePlate: 'ABC-1234',
                    showInstallationScheduled: true,
                  ),
                  const SizedBox(height: 14),
                  _buildApplicationCard(
                    context,
                    lp,
                    title: 'Tech Startup Launch',
                    appliedDate: '2026-01-06',
                    status: lp.translate('pending'),
                    statusColor: const Color(0xFFE0E0E0),
                    statusTextColor: Colors.black,
                    vehicleInfo: '2022 Toyota Camry',
                    licensePlate: 'ABC-1234',
                  ),
                  const SizedBox(height: 14),
                  _buildApplicationCard(
                    context,
                    lp,
                    title: 'Fitness Center Grand Opening',
                    appliedDate: '2026-01-11',
                    status: lp.translate('pending'),
                    statusColor: const Color(0xFFE0E0E0),
                    statusTextColor: Colors.black,
                    vehicleInfo: '2022 Toyota Camry',
                    licensePlate: 'ABC-1234',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    LanguageProvider lp, {
    required String title,
    required String appliedDate,
    required String status,
    required Color statusColor,
    Color statusTextColor = Colors.white,
    required String vehicleInfo,
    required String licensePlate,
    bool showInstallationScheduled = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${lp.translate('applied_on')} $appliedDate',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.directions_car_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lp.translate('vehicle_info'),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 22, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleInfo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        licensePlate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showInstallationScheduled)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 14, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    lp.translate('install_scheduled'),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
