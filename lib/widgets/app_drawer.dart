import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../language_provider.dart';

enum AppRole { driver, advertiser }

class AppDrawer extends StatelessWidget {
  final AppRole role;
  final String activeRoute;
  final Future<void> Function() onLogout;

  const AppDrawer({
    super.key,
    required this.role,
    required this.activeRoute,
    required this.onLogout,
  });

  void _nav(BuildContext context, String route) {
    Navigator.pop(context);
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final subtitle = role == AppRole.driver ? lp.translate('driver') : lp.translate('advertiser');
    final items = role == AppRole.driver ? _driverItems(lp) : _advertiserItems(lp);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: Color(0xFF1D4ED8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      _LogoBox(),
                      SizedBox(width: 12),
                      Text("DrivAd", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ...items.map((it) => _DrawerItem(
              icon: it.icon,
              label: it.label,
              active: activeRoute == it.route,
              onTap: () => _nav(context, it.route),
            )),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(14),
              child: OutlinedButton.icon(
                onPressed: () => onLogout(),
                icon: const Icon(Icons.logout),
                label: Text(lp.translate('logout')),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_DrawerRouteItem> _driverItems(LanguageProvider lp) => [
    _DrawerRouteItem(icon: Icons.grid_view_rounded, label: lp.translate('dashboard'), route: '/dashboard'),
    _DrawerRouteItem(icon: Icons.campaign_rounded, label: lp.translate('campaigns'), route: '/campaigns'),
    _DrawerRouteItem(icon: Icons.description_rounded, label: lp.translate('applications'), route: '/applications'),
    _DrawerRouteItem(icon: Icons.attach_money_rounded, label: lp.translate('earnings'), route: '/earnings'),
    _DrawerRouteItem(icon: Icons.person_outline, label: lp.translate('profile'), route: '/profile'), // ✅ Added Profile
  ];

  List<_DrawerRouteItem> _advertiserItems(LanguageProvider lp) => [
    _DrawerRouteItem(icon: Icons.grid_view_rounded, label: lp.translate('dashboard'), route: '/dashboard'),
    _DrawerRouteItem(icon: Icons.campaign_rounded, label: lp.translate('campaigns'), route: '/campaigns'),
    _DrawerRouteItem(icon: Icons.bar_chart_rounded, label: lp.translate('analytics'), route: '/analytics'),
    _DrawerRouteItem(icon: Icons.person_outline, label: lp.translate('profile'), route: '/profile'), // ✅ Added Profile
  ];
}

class _DrawerRouteItem {
  final IconData icon; final String label; final String route;
  const _DrawerRouteItem({required this.icon, required this.label, required this.route});
}

class _DrawerItem extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: Material(
      color: active ? const Color(0xFFEFF6FF) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12), onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(children: [
            Icon(icon, size: 20, color: active ? const Color(0xFF1D4ED8) : const Color(0xFF6B7280)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: active ? FontWeight.w900 : FontWeight.w700, color: active ? const Color(0xFF1D4ED8) : const Color(0xFF111827))),
          ]),
        ),
      ),
    ),
  );
}

class _LogoBox extends StatelessWidget {
  const _LogoBox();
  @override
  Widget build(BuildContext context) => Container(
    height: 40, width: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: const Icon(Icons.directions_car_filled_rounded, color: Color(0xFF1D4ED8), size: 22),
  );
}
