// lib/dashboards/driver_dashboard_page.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:provider/provider.dart';

import '../language_provider.dart';
import '../auth/auth_service.dart';
import '../widgets/app_drawer.dart';

class DriverDashboardPage extends StatefulWidget {
  final AuthService auth;
  const DriverDashboardPage({super.key, required this.auth});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  final String userName = "John Driver";

  Future<void> _logout() async => widget.auth.logout();

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 900;

    const currentRoute = '/dashboard';

    // Translated Stats with trend data
    final stats = [
      _StatCardData(
        title: lp.translate('total_earnings'),
        value: "\$770",
        icon: Icons.attach_money,
        iconBgColor: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF1976D2),
      ),
      _StatCardData(
        title: lp.translate('active_campaigns'),
        value: "1",
        icon: Icons.campaign_rounded,
        iconBgColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFF57C00),
      ),
      _StatCardData(
        title: lp.translate('completed_campaigns'),
        value: "3",
        icon: Icons.check_circle_outline,
        iconBgColor: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF388E3C),
      ),
      _StatCardData(
        title: lp.translate('monthly_earnings'),
        value: "\$580",
        icon: Icons.trending_up,
        iconBgColor: const Color(0xFFF3E5F5),
        iconColor: const Color(0xFF7B1FA2),
        trend: "↑ 12%",
      ),
    ];

    final recentActivity = [
      _ActivityItem(
        title: lp.lang == 'en'
            ? "Downtown Coffee Shop Promo"
            : "Promo Boutique de Café",
        date: "2026-01-02",
        status: _Status.approved,
      ),
      _ActivityItem(
        title: lp.lang == 'en'
            ? "Tech Startup Launch"
            : "Lancement Startup Tech",
        date: "2026-01-06",
        status: _Status.pending,
      ),
      _ActivityItem(
        title: lp.lang == 'en'
            ? "Fitness Center Grand Opening"
            : "Ouverture Centre Fitness",
        date: "2026-01-11",
        status: _Status.pending,
      ),
    ];

    final earnings = [
      _EarningItem(
        title: lp.lang == 'en' ? "Coffee Shop Promo" : "Promo Boutique de Café",
        period: lp.lang == 'en' ? "January 2026" : "Janvier 2026",
        amount: "\$450",
        status: _EarningStatus.completed,
      ),
      _EarningItem(
        title: lp.lang == 'en'
            ? "Restaurant Week Promotion"
            : "Semaine du Restaurant",
        period: lp.lang == 'en' ? "December 2025" : "Décembre 2025",
        amount: "\$320",
        status: _EarningStatus.completed,
      ),
      _EarningItem(
        title: lp.lang == 'en'
            ? "Tech Startup Launch"
            : "Lancement Startup Tech",
        period: lp.lang == 'en' ? "January 2026" : "Janvier 2026",
        amount: "\$580",
        status: _EarningStatus.pending,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: isMobile
          ? AppDrawer(
              role: AppRole.driver,
              activeRoute: currentRoute,
              onLogout: _logout,
            )
          : null,
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              title: Text(
                lp.translate('dashboard'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1220),
                  fontSize: 20,
                ),
              ),
              actions: [
                _LangChip(
                  label: lp.lang.toUpperCase(),
                  onTap: () => lp.toggleLanguage(),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout,
                    size: 18,
                    color: Color(0xFF666666),
                  ),
                  label: Text(
                    lp.translate('logout'),
                    style: const TextStyle(color: Color(0xFF666666)),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (!isMobile)
              _TopNavDesktop(
                currentRoute: currentRoute,
                lp: lp,
                userName: userName,
                onLogout: _logout,
              ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          lp.translate('statistics'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, c) {
                            final width = c.maxWidth;
                            final columns = width >= 980
                                ? 4
                                : (width >= 360 ? 2 : 1);
                            const gap = 12.0;
                            return _GridWrap(
                              columns: columns,
                              gap: gap,
                              children: stats
                                  .map(
                                    (s) => _StatCard(
                                      title: s.title,
                                      value: s.value,
                                      icon: s.icon,
                                      iconBgColor: s.iconBgColor,
                                      iconColor: s.iconColor,
                                      trend: s.trend,
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          lp.translate('live_campaign_map'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Color(0xFF0B1220),
                          ),
                        ),
                        const SizedBox(height: 12),
                        RepaintBoundary(
                          child: DriverMapPlaceholder(
                            statusLabel: lp.translate('active_zone'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, c) {
                            final isTwoCol = c.maxWidth >= 900;
                            if (isTwoCol) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _Panel(
                                      lp: lp,
                                      title: lp.translate('recent_activity'),
                                      child: Column(
                                        children: recentActivity
                                            .map(
                                              (a) =>
                                                  _ActivityRow(lp: lp, item: a),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _Panel(
                                      lp: lp,
                                      title: lp.translate('earnings'),
                                      child: Column(
                                        children: earnings
                                            .map(
                                              (e) =>
                                                  _EarningRow(lp: lp, item: e),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _Panel(
                                  lp: lp,
                                  title: lp.translate('recent_activity'),
                                  child: Column(
                                    children: recentActivity
                                        .map(
                                          (a) => _ActivityRow(lp: lp, item: a),
                                        )
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _Panel(
                                  lp: lp,
                                  title: lp.translate('earnings'),
                                  child: Column(
                                    children: earnings
                                        .map(
                                          (e) => _EarningRow(lp: lp, item: e),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
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
}

class DriverMapPlaceholder extends StatefulWidget {
  final String statusLabel;

  const DriverMapPlaceholder({super.key, this.statusLabel = "Active Zone"});

  @override
  State<DriverMapPlaceholder> createState() => _DriverMapPlaceholderState();
}

class _DriverMapPlaceholderState extends State<DriverMapPlaceholder> {
  MapboxMap? mapboxMap;
  geo.Position? userPosition;
  String locationText = "Getting GPS location...";
  bool isLoading = true;

  final double defaultLat = 51.0447;
  final double defaultLng = -114.0719;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationText = "GPS disabled - Using default location";
          isLoading = false;
        });
        return;
      }

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          setState(() {
            locationText = "Location permission denied";
            isLoading = false;
          });
          return;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        setState(() {
          locationText = "Location permission denied forever";
          isLoading = false;
        });
        return;
      }

      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        userPosition = position;
        locationText =
            "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
        isLoading = false;
      });

      if (mapboxMap != null) {
        _updateCameraToUserLocation();
      }
    } catch (e) {
      setState(() {
        locationText = "GPS error - Using default location";
        isLoading = false;
      });
      debugPrint('Location error: $e');
    }
  }

  void _onMapCreated(MapboxMap map) async {
    mapboxMap = map;

    if (userPosition != null) {
      _updateCameraToUserLocation();
    } else {
      await Future.delayed(const Duration(seconds: 12));
      if (userPosition == null) {
        _showDefaultLocation();
      }
    }
  }

  Future<void> _updateCameraToUserLocation() async {
    if (mapboxMap == null || userPosition == null) return;

    final userPos = Position(userPosition!.longitude, userPosition!.latitude);

    await mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: userPos),
        zoom: 14.0,
        pitch: 0.0,
        bearing: 0.0,
      ),
      MapAnimationOptions(duration: 1000),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _addZoneCircle(userPos);
    });
  }

  Future<void> _showDefaultLocation() async {
    if (mapboxMap == null) return;

    final defaultPos = Position(defaultLng, defaultLat);

    await mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: defaultPos),
        zoom: 15.0,
        pitch: 0.0,
        bearing: 0.0,
      ),
      MapAnimationOptions(duration: 1000),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _addZoneCircle(defaultPos);
    });
  }

  Future<void> _addZoneCircle(Position center) async {
    try {
      final points = _createCircle(center, 0.003);
      final manager = await mapboxMap!.annotations
          .createPolygonAnnotationManager();
      await manager.create(
        PolygonAnnotationOptions(
          geometry: Polygon(coordinates: [points]),
          fillColor: const Color(0xFF1D4ED8).withValues(alpha: 0.15).toARGB32(),
          fillOutlineColor: const Color(0xFF1D4ED8).toARGB32(),
        ),
      );
    } catch (e) {
      debugPrint('Zone circle error: $e');
    }
  }

  List<Position> _createCircle(Position center, double radius) {
    final List<Position> coords = [];
    for (int i = 0; i <= 360; i += 10) {
      final double angle = i * (math.pi / 180);
      coords.add(
        Position(
          center.lng +
              (radius * math.sin(angle) / math.cos(center.lat * math.pi / 180)),
          center.lat + (radius * math.cos(angle)),
        ),
      );
    }
    return coords;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            MapWidget(
              onMapCreated: _onMapCreated,
              styleUri: MapboxStyles.SATELLITE,
            ),
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "600 ft",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationText.split(", ")[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'SF Mono',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (locationText.contains(", "))
                          Text(
                            locationText.split(", ")[1],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'SF Mono',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF34C759).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNavDesktop extends StatelessWidget {
  final String currentRoute;
  final LanguageProvider lp;
  final String userName;
  final Future<void> Function() onLogout;

  const _TopNavDesktop({
    required this.currentRoute,
    required this.lp,
    required this.userName,
    required this.onLogout,
  });

  void _go(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(
        lp.translate('dashboard'),
        Icons.grid_view_rounded,
        '/dashboard',
      ),
      _NavItemData(
        lp.translate('campaigns'),
        Icons.campaign_rounded,
        '/campaigns',
      ),
      _NavItemData(
        lp.translate('applications'),
        Icons.description_rounded,
        '/applications',
      ),
      _NavItemData(
        lp.translate('earnings'),
        Icons.attach_money_rounded,
        '/earnings',
      ),
      _NavItemData(
        lp.translate('analytics'),
        Icons.bar_chart_rounded,
        '/analytics',
      ),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((it) {
                final selected = it.route == currentRoute;
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _go(context, it.route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF0B1220)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF0B1220)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          it.icon,
                          size: 18,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          it.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _LangChip(
            label: lp.lang.toUpperCase(),
            onTap: () => lp.toggleLanguage(),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.person_outline, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Text(userName, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, size: 18),
            label: Text(lp.translate('logout')),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF111827),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LangChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.language, size: 18, color: Color(0xFF111827)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _GridWrap extends StatelessWidget {
  final int columns;
  final double gap;
  final List<Widget> children;

  const _GridWrap({
    required this.columns,
    required this.gap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final totalGap = gap * (columns - 1);
        final itemWidth = (c.maxWidth - totalGap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((w) => SizedBox(width: itemWidth, child: w))
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? trend;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: Color(0xFF0B1220),
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Text(
              trend!,
              style: const TextStyle(
                color: Color(0xFF34C759),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  final LanguageProvider lp;

  const _Panel({required this.title, required this.child, required this.lp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF0B1220),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityItem item;
  final LanguageProvider lp;

  const _ActivityRow({required this.item, required this.lp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF0B1220),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.date,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(lp: lp, status: item.status),
        ],
      ),
    );
  }
}

class _EarningRow extends StatelessWidget {
  final _EarningItem item;
  final LanguageProvider lp;

  const _EarningRow({required this.item, required this.lp});

  @override
  Widget build(BuildContext context) {
    final statusText = item.status == _EarningStatus.completed
        ? lp.translate('approved')
        : lp.translate('pending');

    final statusColor = item.status == _EarningStatus.completed
        ? const Color(0xFF16A34A)
        : const Color(0xFFF59E0B);

    final statusBgColor = item.status == _EarningStatus.completed
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF9C3);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF0B1220),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.period,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF0B1220),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _Status status;
  final LanguageProvider lp;

  const _StatusChip({required this.status, required this.lp});

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color bg;
    late final Color fg;

    switch (status) {
      case _Status.approved:
        text = lp.translate('approved');
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        break;
      case _Status.pending:
        text = lp.translate('pending');
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFFB45309);
        break;
      case _Status.rejected:
        text = lp.translate('rejected');
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final String route;
  const _NavItemData(this.label, this.icon, this.route);
}

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? trend;
  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.trend,
  });
}

enum _Status { approved, pending, rejected }

class _ActivityItem {
  final String title;
  final String date;
  final _Status status;
  const _ActivityItem({
    required this.title,
    required this.date,
    required this.status,
  });
}

enum _EarningStatus { completed, pending }

class _EarningItem {
  final String title;
  final String period;
  final String amount;
  final _EarningStatus status;
  const _EarningItem({
    required this.title,
    required this.period,
    required this.amount,
    required this.status,
  });
}
