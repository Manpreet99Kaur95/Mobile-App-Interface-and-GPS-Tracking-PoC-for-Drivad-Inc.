import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'auth/auth_service.dart';
import 'widgets/app_drawer.dart';

class EarningsPage extends StatelessWidget {
  final AuthService auth;
  const EarningsPage({super.key, required this.auth});

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
    const currentRoute = '/earnings';

    return FutureBuilder<AppRole>(
      future: _loadRole(),
      builder: (context, snap) {
        final role = snap.data ?? AppRole.driver;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white, elevation: 0,
            title: Text(lp.translate('earnings'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
            actions: [IconButton(onPressed: () => lp.toggleLanguage(), icon: const Icon(Icons.language))],
          ),
          drawer: AppDrawer(role: role, activeRoute: currentRoute, onLogout: _logout),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: EarningStatCard(title: lp.translate('total_earnings'), value: "\$770")),
                      const SizedBox(width: 16),
                      Expanded(child: EarningStatCard(title: lp.translate('pending'), value: "\$580")),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(lp.translate('recent_transactions'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))]),
                    child: Column(
                      children: [
                        EarningTile(title: lp.lang == 'en' ? "Coffee Shop Promo" : "Promo Boutique de Café", amount: "\$450"),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        EarningTile(title: lp.lang == 'en' ? "Restaurant Week" : "Semaine des Restaurants", amount: "\$320"),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        EarningTile(title: lp.lang == 'en' ? "Tech Startup" : "Startup Technologique", amount: "\$580"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class EarningStatCard extends StatelessWidget {
  final String title, value;
  const EarningStatCard({required this.title, required this.value, super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(40), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
  );
}

class EarningTile extends StatelessWidget {
  final String title, amount;
  const EarningTile({required this.title, required this.amount, super.key});
  @override
  Widget build(BuildContext context) => ListTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
}
